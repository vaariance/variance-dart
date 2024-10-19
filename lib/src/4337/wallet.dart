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
class SmartWallet with _PluginManager, _GasSettings implements SmartWalletBase {
  /// The chain configuration.
  final Chain _chain;

  /// The address of the Smart Wallet.
  final EthereumAddress _walletAddress;

  /// The initialization code for deploying the Smart Wallet contract.
  Uint8List _initCode;

  /// Creates a new instance of the [SmartWallet] class.
  ///
  /// [_chain] is an object representing the blockchain chain configuration.
  /// [_walletAddress] is the address of the Smart Wallet.
  /// [_initCode] is the initialization code for deploying the Smart Wallet contract.
  SmartWallet(this._chain, this._walletAddress, this._initCode);

  @override
  EthereumAddress get address => _walletAddress;

  @override
  Future<EtherAmount> get balance => _getBalance();

  @override
  Future<bool> get isDeployed =>
      plugin<Contract>("contract").deployed(_walletAddress);

  @override
  String get initCode => hexlify(_initCode);

  @override
  Future<BigInt> get initCodeGas => _initCodeGas;

  @override
  Future<Uint256> get nonce => _getNonce();

  @override
  String? get toHex => _walletAddress.hexEip55;

  @override
  String get dummySignature => plugin<MSI>('signer').getDummySignature();

  bool get isSafe => hasPlugin("safe");

  /// Returns the estimated gas required for deploying the Smart Wallet contract.
  ///
  /// The gas estimation is performed by interacting with the 'jsonRpc' plugin
  /// and estimating the gas for the initialization code.
  Future<BigInt> get _initCodeGas => plugin<JsonRPCProviderBase>('jsonRpc')
      .estimateGas(_chain.entrypoint.address, initCode);

  @override
  @Deprecated("Not recommended to modify the initcode")
  void dangerouslySetInitCode(Uint8List code) {
    _initCode = code;
  }

  @override
  UserOperation buildUserOperation({
    required Uint8List callData,
    BigInt? customNonce,
  }) {
    return UserOperation.partial(
        callData: callData,
        initCode: _initCode,
        sender: _walletAddress,
        nonce: customNonce);
  }

  @override
  Future<UserOperationResponse> send(
      EthereumAddress recipient, EtherAmount amount) {
    final cd = Contract.execute(_walletAddress,
        to: recipient, amount: amount, isSafe: isSafe);
    return sendUserOperation(buildUserOperation(callData: cd));
  }

  @override
  Future<UserOperationResponse> sendTransaction(
      EthereumAddress to, Uint8List encodedFunctionData,
      {EtherAmount? amount}) {
    final cd = Contract.execute(_walletAddress,
        to: to,
        amount: amount,
        innerCallData: encodedFunctionData,
        isSafe: isSafe);
    return sendUserOperation(buildUserOperation(callData: cd));
  }

  @override
  Future<UserOperationResponse> sendBatchedTransaction(
      List<EthereumAddress> recipients, List<Uint8List> calls,
      {List<EtherAmount>? amounts}) {
    Uint8List cd;
    if (isSafe) {
      final innerCall = plugin<_SafePlugin>('safe')
          .getSafeMultisendCallData(recipients, amounts, calls);
      cd = Contract.executeBatch(
          walletAddress: _walletAddress,
          recipients: [Constants.safeMultiSendaddress],
          amounts: [],
          innerCalls: [innerCall],
          isSafe: true);
      return sendUserOperation(buildUserOperation(callData: cd));
    } else {
      cd = Contract.executeBatch(
          walletAddress: _walletAddress,
          recipients: recipients,
          amounts: amounts,
          innerCalls: calls);
      return sendUserOperation(buildUserOperation(callData: cd));
    }
  }

  @override
  Future<UserOperationResponse> sendSignedUserOperation(UserOperation op) {
    return plugin<BundlerProviderBase>('bundler')
        .sendUserOperation(
            op.toMap(_chain.entrypoint.version), _chain.entrypoint)
        .catchError((e) => throw SendError(e.toString(), op));
  }

  @override
  Future<UserOperationResponse> sendUserOperation(UserOperation op) =>
      prepareUserOperation(op)
          .then(applyCustomGasSettings)
          .then(signUserOperation)
          .then(sendSignedUserOperation);

  @override
  Future<UserOperation> prepareUserOperation(UserOperation op,
      {bool update = true}) async {
    // Update the user operation with the latest nonce and gas prices if needed
    if (update) op = await _updateUserOperation(op);
    // If the 'paymaster' plugin is enabled, intercept the user operation
    if (hasPlugin('paymaster')) {
      op = await plugin<Paymaster>('paymaster').intercept(op);
    }
    // Validate the user operation
    op.validate(op.nonce > BigInt.zero, initCode);
    return op;
  }

  @override
  Future<UserOperation> signUserOperation(UserOperation op,
      {int? index}) async {
    final blockInfo =
        await plugin<JsonRPCProviderBase>('jsonRpc').getBlockInformation();

    calculateOperationHash(UserOperation op) async {
      if (isSafe) {
        return plugin<_SafePlugin>('safe').getSafeOperationHash(op, blockInfo);
      } else {
        return op.hash(_chain);
      }
    }

    signOperationHash(Uint8List opHash, int? index) async {
      final signature =
          await plugin<MSI>('signer').personalSign(opHash, index: index);
      final signatureHex = hexlify(signature);
      if (isSafe) {
        return plugin<_SafePlugin>('safe')
            .getSafeSignature(signatureHex, blockInfo);
      }
      return signatureHex;
    }

    final opHash = await calculateOperationHash(op);
    op.signature = await signOperationHash(opHash, index);
    return op;
  }

  /// Returns the nonce for the Smart Wallet address.
  ///
  /// If the wallet is not deployed, returns 0.
  /// Otherwise, retrieves the nonce by calling the 'getNonce' function on the entrypoint.
  ///
  /// If an error occurs during the nonce retrieval process, a [NonceError] exception is thrown.
  Future<Uint256> _getNonce() {
    return isDeployed.then((deployed) => !deployed
        ? Future.value(Uint256.zero)
        : plugin<Contract>("contract")
            .read(_chain.entrypoint.address, ContractAbis.get('getNonce'),
                "getNonce",
                params: [_walletAddress, BigInt.zero])
            .then((value) => Uint256(value[0]))
            .catchError((e) => throw NonceError(e.toString(), _walletAddress)));
  }

  /// Returns the balance for the Smart Wallet address.
  ///
  /// If an error occurs during the balance retrieval process, a [FetchBalanceError] exception is thrown.
  Future<EtherAmount> _getBalance() {
    return plugin<Contract>("contract").getBalance(_walletAddress).catchError(
        (e) => throw FetchBalanceError(e.toString(), _walletAddress));
  }

  /// Updates the user operation with the latest nonce and gas prices.
  ///
  /// [op] is the user operation to update.
  ///
  /// Returns a [Future] that resolves to the updated [UserOperation] object.
  Future<UserOperation> _updateUserOperation(UserOperation op) async {
    final responses = await Future.wait<dynamic>(
        [_getNonce(), plugin<JsonRPCProviderBase>('jsonRpc').getGasPrice()]);

    op = op.copyWith(
        nonce: op.nonce > BigInt.zero ? op.nonce : responses[0].value,
        initCode: responses[0] > Uint256.zero ? Uint8List(0) : null,
        signature: dummySignature);

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
    return plugin<BundlerProviderBase>('bundler')
        .estimateUserOperationGas(
            op.toMap(_chain.entrypoint.version), _chain.entrypoint)
        .then((opGas) => op.updateOpGas(opGas, fee))
        .catchError((e) => throw GasEstimationError(e.toString(), op));
  }
}
