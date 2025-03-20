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
        _callActions,
        _bundlerActions,
        _jsonRPCActions,
        _paymasterActions,
        _gasOverridesActions,
        _7579Actions {
  /// The chain configuration.
  final Chain _chain;

  /// The address of the Smart Wallet.
  final EthereumAddress _walletAddress;

  /// A valid signer instance
  final MSI _signer;

  /// The initialization code for deploying the Smart Wallet contract.
  Uint8List _initCode;

  /// Creates a new instance of the [SmartWallet] class.
  ///
  /// [_chain] is an object representing the blockchain chain configuration.
  /// [_walletAddress] is the address of the Smart Wallet.
  /// [_initCode] is the initialization code for deploying the Smart Wallet contract.
  /// [_signer] A valid signer instance
  SmartWallet(this._chain, this._walletAddress, this._signer, this._initCode);

  @override
  EthereumAddress get address => _walletAddress;

  @override
  Future<EtherAmount> get balance => _getBalance();

  @override
  Chain get chain => _chain;

  @override
  @Deprecated("Get the dummy signature directly from the signer")
  String get dummySignature => _signer.getDummySignature();

  @override
  String get initCode => hexlify(_initCode);

  @override
  Future<BigInt> get initCodeGas =>
      estimateGas(_chain.entrypoint.address, initCode);

  @override
  Future<bool> get isDeployed => deployed(_walletAddress);

  @override
  @Deprecated("Does not allow getting nonce with key, use `getNonce` instead")
  Future<Uint256> get nonce => getNonce();

  @override
  @Deprecated("get `hex` from wallet [address]. e.g walletInstance.address.hex")
  String? get toHex => _walletAddress.hexEip55;

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
  @Deprecated("Not recommended to modify the initcode externally")
  void dangerouslySetInitCode(Uint8List code) {
    _initCode = code;
  }

  @override
  Future<UserOperation> prepareUserOperation(UserOperation op,
      {bool update = true, Uint256? nonceKey}) async {
    if (update) op = await _updateUserOperation(op, nonceKey: nonceKey);
    op.validate(op.nonce > BigInt.zero, initCode);
    return op;
  }

  @override
  Future<UserOperationResponse> send(
      EthereumAddress recipient, EtherAmount amount,
      {Uint256? nonceKey}) async {
    final cd = is7579Enabled
        ? await get7579ExecuteCalldata(to: recipient, amount: amount)
        : getExecuteCalldata(to: recipient, amount: amount);
    return sendUserOperation(buildUserOperation(callData: cd),
        nonceKey: nonceKey);
  }

  @override
  Future<UserOperationResponse> sendTransaction(
      EthereumAddress to, Uint8List encodedFunctionData,
      {EtherAmount? amount, Uint256? nonceKey}) async {
    final cd = is7579Enabled
        ? await get7579ExecuteCalldata(
            to: to, amount: amount, innerCallData: encodedFunctionData)
        : getExecuteCalldata(
            to: to, amount: amount, innerCallData: encodedFunctionData);
    return sendUserOperation(buildUserOperation(callData: cd),
        nonceKey: nonceKey);
  }

  @override
  Future<UserOperationResponse> sendBatchedTransaction(
      List<EthereumAddress> recipients, List<Uint8List> calls,
      {List<EtherAmount>? amounts, Uint256? nonceKey}) async {
    final cd = is7579Enabled
        ? await get7579ExecuteBatchCalldata(
            recipients: recipients, amounts: amounts, innerCalls: calls)
        : getExecuteBatchCalldata(
            recipients: recipients, amounts: amounts, innerCalls: calls);
    return sendUserOperation(buildUserOperation(callData: cd),
        nonceKey: nonceKey);
  }

  @override
  Future<UserOperation> signUserOperation(UserOperation op,
      {int? index}) async {
    final blockInfo = await getBlockInformation();

    getHashFn() => getUserOperationHash(op, blockInfo);
    final sign = _getUserOperationSignHandler(getHashFn);
    final getSignature = await sign(_signer.personalSign, index);

    op.signature = getSignature(blockInfo);
    return op;
  }

  @override
  Future<UserOperationResponse> sendSignedUserOperation(UserOperation op) {
    return sendRawUserOperation(
            op.toMap(_chain.entrypoint.version), _chain.entrypoint)
        .catchError((e) => throw SendError(e.toString(), op));
  }

  @override
  Future<UserOperationResponse> sendUserOperation(UserOperation op,
          {Uint256? nonceKey}) =>
      prepareUserOperation(op, nonceKey: nonceKey)
          .then(_applyGasOverrides)
          .then(sponsorUserOperation)
          .then(signUserOperation)
          .then(sendSignedUserOperation);

  @override
  Future<Uint256> getNonce([Uint256? key]) {
    return isDeployed.then((deployed) => !deployed
        ? Future.value(Uint256.zero)
        : readContract(_chain.entrypoint.address, ContractAbis.get('getNonce'),
                "getNonce", params: [_walletAddress, key?.value ?? BigInt.zero])
            .then((value) => Uint256(value[0]))
            .catchError((e) => throw NonceError(e.toString(), _walletAddress)));
  }

  /// Returns the balance for the Smart Wallet address.
  ///
  /// If an error occurs during the balance retrieval process, a [FetchBalanceError] exception is thrown.
  Future<EtherAmount> _getBalance() {
    return balanceOf(_walletAddress).catchError(
        (e) => throw FetchBalanceError(e.toString(), _walletAddress));
  }

  /// Updates the user operation with the latest nonce and gas prices.
  ///
  /// [op] is the user operation to update.
  ///
  /// Returns a [Future] that resolves to the updated [UserOperation] object.
  Future<UserOperation> _updateUserOperation(UserOperation op,
      {Uint256? nonceKey}) async {
    final responses =
        await Future.wait<dynamic>([getNonce(nonceKey), getGasPrice()]);

    op = op.copyWith(
        nonce: op.nonce > BigInt.zero ? op.nonce : responses[0].value,
        initCode: responses[0] > Uint256.zero ? Uint8List(0) : null,
        signature: _signer.getDummySignature());

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
    return estimateUserOperationGas(
            op.toMap(_chain.entrypoint.version), _chain.entrypoint)
        .then((opGas) => op.updateOpGas(opGas, fee))
        .catchError((e) => throw GasEstimationError(e.toString(), op));
  }

  /// Initializes the smart wallet instance with required components and actions
  ///
  /// @dev prevents a smartwallet instance from being instantiated without using the factory
  /// [initializer] safe 7579 initializer for safeSetup
  /// [rpc] Optional RPC client, will create new one if not provided
  /// [safe] Optional Safe module for safe accounts
  void _initialize(
      [RPCBase? rpc, _SafeModule? safe, _SafeInitializer? initializer]) {
    // Create new RPC client if none provided, using chain's JSON RPC URL
    rpc = rpc ?? RPCBase(_chain.jsonRpcUrl!);

    // Set the Safe module if provided
    _safe = safe;

    // Initialize all required action modules
    _setup7579Actions(initializer); // Setup ERC-7579 related actions
    _setupBundlerActions(_chain); // Setup bundler communication
    _setupJsonRpcActions(rpc); // Setup JSON RPC interactions
    _setupPaymasterActions(); // Setup paymaster related functionality
  }
}
