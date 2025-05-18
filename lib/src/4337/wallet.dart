part of '../../variance_dart.dart';

/// A class that represents a Smart Wallet on an Ethereum-like blockchain.
///
/// The [SmartWallet] class implements the [SmartWalletBase] interface and provides
/// various methods for interacting with the wallet, such as sending transactions,
/// estimating gas, and retrieving balances. It uses various plugins for different
/// functionalities, such as contract interaction, gas estimation, and signing operations.
///
/// The class utilizes the `_PluginManager` and `_GasSettings` mixins for managing plugins
/// and gas settings, respectively.
///
/// Example usage:
///
/// ```dart
/// // Create a new instance of the SmartWallet
/// final wallet = SmartWallet(chain, walletAddress, initCode);
///
/// // Get the wallet balance
/// final balance = await wallet.balance;
///
/// // Send a transaction
/// final recipient = EthereumAddress.fromHex('0x...');
/// final amount = EtherAmount.fromUnitAndValue(EtherUnit.ether, 1);
/// final response = await wallet.send(recipient, amount);
/// ```
class SmartWallet extends SmartWalletBase
    with
        _CallActions,
        _BundlerActions,
        _JsonRPCActions,
        _PaymasterActions,
        _GasOverridesActions,
        _Safe7579Actions {
  final SmartWalletState _state;

  SmartWallet(this._state);

  @override
  EthereumAddress get address => _state.address;

  @override
  Future<EtherAmount> get balance => _getBalance();

  @override
  Chain get chain => _state.chain;

  @override
  @Deprecated("Get the dummy signature directly from the signer")
  String get dummySignature => _state.signer.getDummySignature();

  @override
  String get initCode => hexlify(_state.initCode);

  @override
  Future<BigInt> get initCodeGas =>
      estimateGas(_state.chain.entrypoint.address, initCode);

  @override
  Future<bool> get isDeployed => deployed(_state.address);

  @override
  @Deprecated("Does not allow getting nonce with key, use `getNonce` instead")
  Future<Uint256> get nonce => getNonce();

  @override
  @Deprecated("get `hex` from wallet [address]. e.g walletInstance.address.hex")
  String? get toHex => _state.address.hexEip55;

  @protected
  @override
  SmartWalletState get state => _state;

  @override
  UserOperation buildUserOperation({
    required Uint8List callData,
    BigInt? customNonce,
  }) {
    return UserOperation.partial(
      callData: callData,
      initCode: _state.initCode,
      sender: _state.address,
      nonce: customNonce,
    );
  }

  @override
  Future<UserOperation> prepareUserOperation(
    UserOperation op, {
    bool update = true,
    Uint256? nonceKey,
  }) async {
    if (update) op = await _updateUserOperation(op, nonceKey: nonceKey);
    op.validate(op.nonce > BigInt.zero, initCode);
    return op;
  }

  @override
  Future<UserOperationResponse> send(
    EthereumAddress recipient,
    EtherAmount amount, {
    Uint256? nonceKey,
  }) async {
    final cd =
        _state.safe?.isSafe7579 ?? false
            ? await get7579ExecuteCalldata(to: recipient, amount: amount)
            : getExecuteCalldata(to: recipient, amount: amount);
    return sendUserOperation(
      buildUserOperation(callData: cd),
      nonceKey: nonceKey,
    );
  }

  @override
  Future<UserOperationResponse> sendTransaction(
    EthereumAddress to,
    Uint8List encodedFunctionData, {
    EtherAmount? amount,
    Uint256? nonceKey,
  }) async {
    final cd =
        _state.safe?.isSafe7579 ?? false
            ? await get7579ExecuteCalldata(
              to: to,
              amount: amount,
              innerCallData: encodedFunctionData,
            )
            : getExecuteCalldata(
              to: to,
              amount: amount,
              innerCallData: encodedFunctionData,
            );
    return sendUserOperation(
      buildUserOperation(callData: cd),
      nonceKey: nonceKey,
    );
  }

  @override
  Future<UserOperationResponse> sendBatchedTransaction(
    List<EthereumAddress> recipients,
    List<Uint8List> calls, {
    List<EtherAmount>? amounts,
    Uint256? nonceKey,
  }) async {
    final cd =
        _state.safe?.isSafe7579 ?? false
            ? await get7579ExecuteBatchCalldata(
              recipients: recipients,
              amounts: amounts,
              innerCalls: calls,
            )
            : getExecuteBatchCalldata(
              recipients: recipients,
              amounts: amounts,
              innerCalls: calls,
            );
    return sendUserOperation(
      buildUserOperation(callData: cd),
      nonceKey: nonceKey,
    );
  }

  @override
  Future<UserOperation> signUserOperation(
    UserOperation op, {
    int? index,
  }) async {
    final blockInfo = await getBlockInformation();
    op.signature = await generateSignature(op, blockInfo, index);
    return op;
  }

  @override
  Future<UserOperationResponse> sendSignedUserOperation(UserOperation op) {
    final chain = _state.chain;
    return sendRawUserOperation(
      op.toMap(chain.entrypoint.version),
      chain.entrypoint,
    ).catchError((e) => throw SendError(e.toString(), op));
  }

  @override
  Future<UserOperationResponse> sendUserOperation(
    UserOperation op, {
    Uint256? nonceKey,
  }) => prepareUserOperation(op, nonceKey: nonceKey)
      .then(_applyGasOverrides)
      .then(sponsorUserOperation)
      .then(signUserOperation)
      .then(sendSignedUserOperation);

  @override
  Future<Uint256> getNonce([Uint256? key]) {
    return isDeployed.then(
      (deployed) =>
          !deployed
              ? Future.value(Uint256.zero)
              : readContract(
                    _state.chain.entrypoint.address,
                    ContractAbis.get('getNonce'),
                    "getNonce",
                    params: [_state.address, key?.value ?? BigInt.zero],
                  )
                  .then((value) => Uint256(value[0]))
                  .catchError(
                    (e) => throw NonceError(e.toString(), _state.address),
                  ),
    );
  }

  @protected
  Future<String> generateSignature(
    UserOperation op,
    dynamic blockInfo,
    int? index,
  ) async {
    getHashFn() => getUserOperationHash(op, blockInfo);
    final sign = _getUserOperationSignHandler(getHashFn);
    final getSignature = await sign(_state.signer.personalSign, index);
    return getSignature(blockInfo);
  }

  /// Returns the balance for the Smart Wallet address.
  ///
  /// If an error occurs during the balance retrieval process, a [FetchBalanceError] exception is thrown.
  Future<EtherAmount> _getBalance() {
    return balanceOf(
      _state.address,
    ).catchError((e) => throw FetchBalanceError(e.toString(), _state.address));
  }

  /// Updates the user operation with the latest nonce and gas prices.
  ///
  /// [op] is the user operation to update.
  ///
  /// Returns a [Future] that resolves to the updated [UserOperation] object.
  Future<UserOperation> _updateUserOperation(
    UserOperation op, {
    Uint256? nonceKey,
  }) async {
    final responses = await Future.wait<dynamic>([
      getNonce(nonceKey),
      getGasPrice(),
      getBlockInformation(),
    ]);
    final dummySignature = _state.signer.getDummySignature();
    final signature =
        _state.safe?.isSafe7579 ?? false
            ? _state.safe?.module.getSafeSignature(dummySignature, responses[2])
            : dummySignature;

    op = op.copyWith(
      nonce: op.nonce > BigInt.zero ? op.nonce : responses[0].value,
      initCode: responses[0] > Uint256.zero ? Uint8List(0) : null,
      signature: signature,
    );

    return _updateUserOperationGas(op, responses[1]);
  }

  /// Updates the gas information for the user operation.
  ///
  /// [op] is the user operation to update.
  /// [fee] is an optional Fee containing the gas prices.
  ///
  /// Returns a [Future] that resolves to the updated [UserOperation] object.
  ///
  /// If an error occurs during the gas estimation process, a [GasEstimationError] exception is thrown.
  Future<UserOperation> _updateUserOperationGas(UserOperation op, Fee fee) {
    final chain = _state.chain;
    return estimateUserOperationGas(
          op.toMap(chain.entrypoint.version),
          chain.entrypoint,
        )
        .then((opGas) => op.updateOpGas(opGas, fee))
        .catchError((e) => throw GasEstimationError(e.toString(), op));
  }
}
