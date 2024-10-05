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

  /// Defines the signer type for Alchemy Light Accounts.
  final Uint8List _prefix;

  /// Creates a new instance of the [SmartWallet] class.
  ///
  /// [_chain] is an object representing the blockchain chain configuration.
  /// [_walletAddress] is the address of the Smart Wallet.
  /// [_initCode] is the initialization code for deploying the Smart Wallet contract.
  /// [prefix] is the signature prefix for signing light account transactions.
  SmartWallet(this._chain, this._walletAddress, this._initCode,
      [Uint8List? signaturePrefix])
      : _prefix = signaturePrefix ?? Uint8List(0);

  @override
  EthereumAddress get address => _walletAddress;

  @override
  Future<EtherAmount> get balance =>
      plugin<Contract>("contract").getBalance(_walletAddress);

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
  String get dummySignature =>
      plugin<MSI>('signer').getDummySignature(prefix: hexlify(_prefix));

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
  }) =>
      UserOperation.partial(
          callData: callData,
          initCode: _initCode,
          sender: _walletAddress,
          nonce: customNonce);

  @override
  Future<UserOperationResponse> send(
          EthereumAddress recipient, EtherAmount amount) =>
      sendUserOperation(buildUserOperation(
          callData: Contract.execute(_walletAddress,
              to: recipient, amount: amount, isSafe: hasPlugin("safe"))));

  @override
  Future<UserOperationResponse> sendTransaction(
          EthereumAddress to, Uint8List encodedFunctionData,
          {EtherAmount? amount}) =>
      sendUserOperation(buildUserOperation(
          callData: Contract.execute(_walletAddress,
              to: to,
              amount: amount,
              innerCallData: encodedFunctionData,
              isSafe: hasPlugin("safe"))));

  @override
  Future<UserOperationResponse> sendBatchedTransaction(
      List<EthereumAddress> recipients, List<Uint8List> calls,
      {List<EtherAmount>? amounts}) {
    final isSafe = hasPlugin("safe");
    if (isSafe) {
      final innerCall = plugin<_SafePlugin>('safe')
          .getSafeMultisendCallData(recipients, amounts, calls);
      return sendUserOperation(buildUserOperation(
          callData: Contract.executeBatch(
              walletAddress: _walletAddress,
              recipients: [Constants.safeMultiSendaddress],
              amounts: [],
              innerCalls: [innerCall],
              isSafe: true)));
    } else {
      return sendUserOperation(buildUserOperation(
          callData: Contract.executeBatch(
              walletAddress: _walletAddress,
              recipients: recipients,
              amounts: amounts,
              innerCalls: calls)));
    }
  }

  @override
  Future<UserOperationResponse> sendSignedUserOperation(UserOperation op) =>
      plugin<BundlerProviderBase>('bundler')
          .sendUserOperation(
              op.toMap(_chain.entrypoint.version), _chain.entrypoint)
          .catchError((e) => throw SendError(e.toString(), op));

  @override
  Future<UserOperationResponse> sendUserOperation(UserOperation op) =>
      prepareUserOperation(op)
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
    final isSafe = hasPlugin('safe');
    final blockInfo =
        await plugin<JsonRPCProviderBase>('jsonRpc').getBlockInformation();

    // Calculate the operation hash
    final opHash = isSafe
        ? await plugin<_SafePlugin>('safe').getSafeOperationHash(op, blockInfo)
        : op.hash(_chain);

    // Sign the operation hash using the 'signer' plugin
    final signature =
        await plugin<MSI>('signer').personalSign(opHash, index: index);

    // Append the signature validity period if the 'safe' plugin is enabled
    op.signature = isSafe
        ? plugin<_SafePlugin>('safe').getSafeSignature(signature, blockInfo)
        : hexlify(_prefix + signature);

    return op;
  }

  /// Returns the nonce for the Smart Wallet address.
  ///
  /// If the wallet is not deployed, returns 0.
  /// Otherwise, retrieves the nonce by calling the 'getNonce' function on the entrypoint.
  ///
  /// If an error occurs during the nonce retrieval process, a [NonceError] exception is thrown.
  Future<Uint256> _getNonce() => isDeployed.then((deployed) => !deployed
      ? Future.value(Uint256.zero)
      : plugin<Contract>("contract")
          .read(_chain.entrypoint.address, ContractAbis.get('getNonce'),
              "getNonce",
              params: [_walletAddress, BigInt.zero])
          .then((value) => Uint256(value[0]))
          .catchError((e) => throw NonceError(e.toString(), _walletAddress)));

  /// Updates the user operation with the latest nonce and gas prices.
  ///
  /// [op] is the user operation to update.
  ///
  /// Returns a [Future] that resolves to the updated [UserOperation] object.
  Future<UserOperation> _updateUserOperation(UserOperation op) =>
      Future.wait<dynamic>([
        _getNonce(),
        plugin<JsonRPCProviderBase>('jsonRpc').getGasPrice()
      ]).then((responses) {
        op = op.copyWith(
            nonce: op.nonce > BigInt.zero ? op.nonce : responses[0].value,
            initCode: responses[0] > Uint256.zero ? Uint8List(0) : null,
            signature: dummySignature);

        return _updateUserOperationGas(op, feePerGas: responses[1]);
      });

  /// Updates the gas information for the user operation.
  ///
  /// [op] is the user operation to update.
  /// [feePerGas] is an optional map containing the gas prices.
  ///
  /// Returns a [Future] that resolves to the updated [UserOperation] object.
  ///
  /// If an error occurs during the gas estimation process, a [GasEstimationError] exception is thrown.
  Future<UserOperation> _updateUserOperationGas(UserOperation op,
          {Map<String, EtherAmount>? feePerGas}) =>
      plugin<BundlerProviderBase>('bundler')
          .estimateUserOperationGas(
              op.toMap(_chain.entrypoint.version), _chain.entrypoint)
          .then((opGas) => op.updateOpGas(opGas, feePerGas))
          .then((op) => applyCustomGasSettings(op))
          .catchError((e) => throw GasEstimationError(e.toString(), op));
}
