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
/// final recipient = Address.fromHex('0x...');
/// final amount = BigInt.from(1e18);
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
  Address get address => _state.address;

  @override
  Future<BigInt> get balance => _getBalance();

  @override
  Chain get chain => _state.chain;

  @override
  @protected
  String get dummySignature => _state.signer.getDummySignature();

  @override
  String get initCode => hexlify(_state.initCode);

  @override
  Future<BigInt> get initCodeGas =>
      estimateGas(_state.chain.entrypoint.address, initCode);

  @override
  Future<bool> get isDeployed => deployed(_state.address);

  @protected
  @override
  SmartWalletState get state => _state;

  @override
  Future<UserOperationResponse> send(
    Address recipient,
    BigInt amountInWei, {
    Address? token,
    Uint256? nonceKey,
  }) async {
    final cd = await _getTransferCalldata(recipient, amountInWei, token);
    return sendUserOperation(
      buildUserOperation(callData: cd),
      nonceKey: nonceKey,
    );
  }

  @override
  Future<UserOperationResponse> sendTransaction(
    Address to,
    Uint8List encodedFunctionData, {
    BigInt? amountInWei,
    Uint256? nonceKey,
  }) async {
    final cd = await _getExecuteBatchCalldata(
      targets: [to],
      values: amountInWei != null ? [amountInWei] : null,
      calls: [encodedFunctionData],
    );
    return sendUserOperation(
      buildUserOperation(callData: cd),
      nonceKey: nonceKey,
    );
  }

  @override
  Future<UserOperationResponse> sendBatchedTransaction(
    List<Address> recipients,
    List<Uint8List> calls, {
    List<BigInt>? amountsInWei,
    Uint256? nonceKey,
  }) async {
    final cd = await _getExecuteBatchCalldata(
      targets: recipients,
      values: amountsInWei,
      calls: calls,
    );
    return sendUserOperation(
      buildUserOperation(callData: cd),
      nonceKey: nonceKey,
    );
  }

  @override
  Future<UserOperationResponse> sendUserOperation(
    UserOperation op, {
    Uint256? nonceKey,
  }) {
    return prepareUserOperation(op, nonceKey: nonceKey)
        .then(overrideGas)
        .then(sponsorUserOperation)
        .then(signUserOperation)
        .then(sendSignedUserOperation);
  }

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
    Uint256? nonceKey,
  }) async {
    getSig(BlockInfo blockInfo) {
      final defaultSignature = _state.signer.getDummySignature();
      final isNotModified = dummySignature == defaultSignature;

      if (isNotModified && _state.safe != null) {
        return _state.safe?.module.getSafeSignature(
          defaultSignature,
          blockInfo,
        );
      }
      return dummySignature;
    }

    final responses = await Future.wait<dynamic>([
      getNonce(nonceKey),
      getGasPrice(),
      getBlockInformation(),
      isDeployed,
    ]);

    final nonce = op.nonce > BigInt.zero ? op.nonce : responses[0].value;

    op = op.copyWith(
      nonce: nonce,
      initCode: responses[3] ? Uint8List(0) : null,
      signature: getSig(responses[2]),
    );

    op = await _updateUserOperationGas(op, responses[1]);
    op.validate(responses[3], initCode);
    return op;
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
  Future<Uint256> getNonce([Uint256? key]) {
    return readContract(
          _state.chain.entrypoint.address,
          ContractAbis.get('getNonce'),
          "getNonce",
          params: [_state.address, key?.value ?? BigInt.zero],
        )
        .then((value) => Uint256(value.first))
        .catchError((e) => throw NonceError(e.toString(), _state.address));
  }

  @override
  @protected
  Future<String> generateSignature(
    UserOperation op,
    BlockInfo blockInfo,
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
  Future<BigInt> _getBalance() {
    return balanceOf(
      _state.address,
    ).catchError((e) => throw FetchBalanceError(e.toString(), _state.address));
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

  /// Gets the calldata for executing a transaction through the smart wallet.
  /// All transactions are batch executed through the smart wallet.
  /// This method generates the appropriate calldata based on whether the wallet
  /// is using Safe 7579 standard or not.
  ///
  /// Parameters:
  /// - [targets]: a list of target addresses for the transaction
  /// - [values]: Optional list of ETH amounts to send with the transaction
  /// - [calls]: Optional list of encoded function data to execute
  ///
  /// Returns a [Future<Uint8List>] containing the encoded calldata for execution.
  Future<Uint8List> _getExecuteBatchCalldata({
    required List<Address> targets,
    required List<Uint8List> calls,
    List<BigInt>? values,
  }) async {
    final isSafe7579 = _state.safe?.isSafe7579 ?? false;
    return isSafe7579
        ? get7579ExecuteBatchCalldata(
          recipients: targets,
          amountsInWei: values,
          innerCalls: calls,
        )
        : getExecuteBatchCalldata(
          recipients: targets,
          amountsInWei: values,
          innerCalls: calls,
        );
  }

  /// Gets the calldata for transferring ETH or ERC20 tokens through the smart wallet.
  ///
  /// For ETH transfers:
  /// - Creates a batch transaction with the recipient address
  /// - Includes the ETH amount in values
  /// - Uses empty calldata
  ///
  /// For ERC20 transfers:
  /// - Creates a batch transaction targeting the token contract
  /// - Encodes the transfer function call with recipient and amount
  /// - No ETH value is included
  ///
  /// Parameters:
  /// - [recipient]: The address receiving the transfer
  /// - [amountInWei]: The amount of ETH/tokens to transfer
  /// - [token]: Optional ERC20 token address. If null, transfers ETH
  ///
  /// Returns a [Future<Uint8List>] containing the encoded transfer calldata.
  Future<Uint8List> _getTransferCalldata(
    Address recipient,
    BigInt amountInWei,
    Address? token,
  ) {
    if (token == null) {
      return _getExecuteBatchCalldata(
        targets: [recipient],
        values: [amountInWei],
        calls: [Uint8List(0)],
      );
    }
    final transferData = ContractUtils.encodeERC20TransferCall(
      token,
      recipient,
      amountInWei,
    );
    return _getExecuteBatchCalldata(
      targets: [token],
      values: null,
      calls: [transferData],
    );
  }
}
