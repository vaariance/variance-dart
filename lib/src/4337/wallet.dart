part of 'package:variance_dart/variance.dart';

class SmartWallet with _PluginManager implements SmartWalletBase {
  final Chain _chain;

  Address? _walletAddress;
  String? _initCode;

  /// [Entrypoint] is not initialized
  /// to initialize with entrypoint, you have to call [SmartWallet.initialize] instead
  ///
  /// - [bundler]: us the bundler provider e.g voltaire, alto, stackup ...
  /// - [ethRpc]: The Ethereum RPC endpoint URL. e.g infura, alchemy, quicknode
  ///
  /// Creates an instance of [SmartWallet]
  SmartWallet(
      {required Chain chain,
      required MultiSignerInterface signer,
      required BundlerProviderBase bundler,
      required RPCProviderBase ethRpc,
      Address? address})
      : _chain = chain.validate(),
        _walletAddress = address {
    addPlugin<MultiSignerInterface>('signer', signer);
    addPlugin<BundlerProviderBase>('bundler', bundler);
    addPlugin<RPCProviderBase>('ethRpc', ethRpc);
    addPlugin<Contract>('contract', Contract(ethRpc));
    addPlugin<AccountFactoryBase>(
        'factory',
        _AccountFactory(
            address: chain.accountFactory,
            chainId: chain.chainId,
            rpc: ethRpc));
  }

  /// Initializes the [SmartWallet] instance and the associated [Entrypoint] contract.
  ///
  /// Use this method directly when you need to interact with the entrypoint,
  /// wait for user Operation Events, or recovering an account.
  ///
  /// - [chain]: The blockchain chain.
  /// - [signer]: required multi-signer interface
  /// - [bundler]: The bundler provider.
  /// - [ethRpc]: The Ethereum RPC endpoint URL.
  /// - [address]: The Ethereum address (optional).
  factory SmartWallet.init(
      {required Chain chain,
      required MultiSignerInterface signer,
      required BundlerProviderBase bundler,
      required RPCProviderBase ethRpc,
      Address? address}) {
    final instance = SmartWallet(
        chain: chain,
        signer: signer,
        bundler: bundler,
        ethRpc: ethRpc,
        address: address);
    instance
        .plugin<BundlerProviderBase>('bundler')
        .initializeWithEntrypoint(Entrypoint(
          address: chain.entrypoint,
          client: instance.plugin<_AccountFactory>('factory').client,
        ));
    return instance;
  }

  @override
  Address? get address => _walletAddress;

  @override
  Future<EtherAmount> get balance async =>
      await plugin<Contract>("contract").getBalance(_walletAddress);

  @override
  Future<bool> get deployed async =>
      await plugin<Contract>("contract").deployed(_walletAddress);

  @override
  Future<Uint256> get nonce async => await _getNonce();

  @override
  String? get toHex => _walletAddress?.hexEip55;

  @override
  UserOperation buildUserOperation(
    Uint8List callData, {
    BigInt? customNonce,
    BigInt? callGasLimit,
    BigInt? verificationGasLimit,
    BigInt? preVerificationGas,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
  }) {
    return UserOperation.partial(
      hexlify(callData),
      sender: _walletAddress,
      nonce: customNonce,
      callGasLimit: callGasLimit,
      verificationGasLimit: verificationGasLimit,
      preVerificationGas: preVerificationGas,
      maxFeePerGas: maxFeePerGas,
      maxPriorityFeePerGas: maxPriorityFeePerGas,
    );
  }

  @override
  Future createSimpleAccount(Uint256 salt, {int? index}) async {
    EthereumAddress signer = EthereumAddress.fromHex(
        plugin<MultiSignerInterface>('signer').getAddress());
    _initCode = hexlify(_getInitCode('createAccount', [signer, salt.value]));
    getSimpleAccountAddress(signer, salt)
        .then((value) => {_walletAddress = value});
  }

  @override
  Future createSimplePasskeyAccount(PassKeyPair pkp, Uint256 salt) async {
    _initCode = hexlify(_getInitCode('createPasskeyAccount', [
      pkp.credentialHexBytes,
      pkp.publicKey[0].value,
      pkp.publicKey[1].value,
      salt.value
    ]));
    getSimplePassKeyAccountAddress(pkp, salt)
        .then((addr) => {_walletAddress = addr});
  }

  @override
  Future<Address> getSimpleAccountAddress(
      EthereumAddress signer, Uint256 salt) async {
    final EthereumAddress address =
        await plugin<_AccountFactory>('factory').getAddress(signer, salt.value);
    return Address.fromEthAddress(address);
  }

  @override
  Future<Address> getSimplePassKeyAccountAddress(
      PassKeyPair pkp, Uint256 salt) async {
    final EthereumAddress address = await plugin<_AccountFactory>('factory')
        .getPasskeyAccountAddress(pkp.credentialHexBytes,
            pkp.publicKey[0].value, pkp.publicKey[1].value, salt.value);
    return Address.fromEthAddress(address);
  }

  @override
  Future<UserOperationResponse> send(
      EthereumAddress recipient, EtherAmount amount) async {
    require(_walletAddress != null, 'Wallet not deployed');
    return sendUserOperation(buildUserOperation(
        Contract.execute(_walletAddress!, to: recipient, amount: amount)));
  }

  @override
  Future<UserOperationResponse> sendBatchedTransaction(
      List<EthereumAddress> recipients, List<Uint8List> calls,
      {List<EtherAmount>? amounts}) async {
    require(_walletAddress != null, 'Wallet not deployed');
    return sendUserOperation(buildUserOperation(Contract.executeBatch(
        walletAddress: _walletAddress!,
        recipients: recipients,
        amounts: amounts,
        innerCalls: calls)));
  }

  @override
  Future<UserOperationResponse> sendSignedUserOperation(
      UserOperation op) async {
    return plugin<BundlerProviderBase>('bundler')
        .sendUserOperation(op.toMap(), _chain.entrypoint);
  }

  @override
  Future<UserOperationResponse> sendTransaction(
      EthereumAddress to, Uint8List encodedFunctionData,
      {EtherAmount? amount}) async {
    require(_walletAddress != null, 'Wallet not deployed');
    return sendUserOperation(buildUserOperation(Contract.execute(
        _walletAddress!,
        to: to,
        amount: amount,
        innerCallData: encodedFunctionData)));
  }

  @override
  Future<UserOperationResponse> sendUserOperation(UserOperation op,
      {String? id}) async {
    return signUserOperation(op, id: id).then(sendSignedUserOperation);
  }

  @override
  Future<UserOperation> signUserOperation(UserOperation userOp,
      {bool update = true, String? id, int? index}) async {
    if (update) await _updateUserOperation(userOp);
    final opHash = userOp.hash(_chain);
    Uint8List signature = await plugin<MultiSignerInterface>('signer')
        .personalSign(opHash,
            index: index,
            id: id ?? plugin<PasskeyInterface>('signer').defaultId);
    userOp.signature = hexlify(signature);
    await _validateUserOperation(userOp);
    return userOp;
  }

  Uint8List _getInitCode(String functionName, List params) {
    final factory = plugin<_AccountFactory>('factory');
    final data = factory.self.function(functionName).encodeCall(params);
    final initCode =
        abi.encode(['address', 'bytes'], [factory.self.address, data]);
    return initCode;
  }

  Future<BigInt> _getInitCodeGas() {
    require(_initCode != null, "No init code");
    return plugin<RPCProviderBase>('ethRpc')
        .estimateGas(_chain.entrypoint, _initCode!);
  }

  Future<Uint256> _getNonce() async {
    if (_walletAddress == null) {
      return Uint256.zero;
    }
    return plugin<Contract>("contract")
        .call(_walletAddress!, ContractAbis.get('getNonce'), "getNonce")
        .then((value) => Uint256(value[0]))
        .catchError((e) => Uint256.zero);
  }

  Future _updateUserOperation(UserOperation op) async {
    final map = op.toMap();
    List<dynamic> reponses = await Future.wait([
      plugin<BundlerProviderBase>('bundler')
          .estimateUserOperationGas(map, _chain.entrypoint),
      plugin<RPCProviderBase>('ethRpc').getGasPrice(),
      nonce,
      deployed
    ]);
    op = UserOperation.update(map, reponses[0],
        sender: _walletAddress,
        nonce: reponses[2].value,
        initCode: !(reponses[3]) ? _initCode! : null);
    op.maxFeePerGas = reponses[1]["maxFeePerGas"] as BigInt;
    op.maxPriorityFeePerGas = reponses[1]["maxPriorityFeePerGas"] as BigInt;
  }

  Future<void> _validateUserOperation(UserOperation op) async {
    require(op.sender.hex == _walletAddress?.hex && _walletAddress != null,
        "Operation sender error. ${op.sender} provided.");
    require(op.initCode == ((await deployed) ? "0x" : _initCode!),
        "Init code mismatch");
    require(op.callGasLimit >= BigInt.from(35000),
        "Call gas limit too small expected value greater than 35000");
    require(op.verificationGasLimit >= BigInt.from(70000),
        "Verification gas limit too small expected value greater than 70000");
    require(op.preVerificationGas >= BigInt.from(21000),
        "Pre verification gas too small expected value greater than 21000");
    require(op.callData.length >= 4, "Call data too short, min is 4 bytes");
    require(op.signature.length >= 64, "Signature too short, min is 32 bytes");
  }
}
