part of '../../variance.dart';

class SmartWallet with _PluginManager, _GasSettings implements SmartWalletBase {
  final Chain _chain;

  EthereumAddress? _walletAddress;

  Uint8List? _initCalldata;

  bool? _deployed;

  SmartWallet(
      {required Chain chain,
      required MultiSignerInterface signer,
      required BundlerProviderBase bundler})
      : _chain = chain.validate() {
    final rpc = RPCProvider(chain.ethRpcUrl!);
    final fact = _AccountFactory(
        address: chain.accountFactory!, chainId: chain.chainId, rpc: rpc);

    addPlugin('signer', signer);
    addPlugin('bundler', bundler);
    addPlugin('ethRpc', rpc);
    addPlugin('contract', Contract(rpc));
    addPlugin('factory', fact);
  }

  /// Initializes a [SmartWallet] instance for a specific chain with the provided parameters.
  ///
  /// Parameters:
  ///   - `chain`: The blockchain [Chain] associated with the smart wallet.
  ///   - `signer`: The [MultiSignerInterface] responsible for signing transactions.
  ///   - `bundler`: The [BundlerProviderBase] that provides bundling services.
  ///   - `address`: Optional Ethereum address associated with the smart wallet.
  ///   - `initCallData`: Optional initialization calldata of the factory create method as a [Uint8List].
  ///
  /// Returns:
  ///   A fully initialized [SmartWallet] instance.
  ///
  /// Example:
  /// ```dart
  /// var smartWallet = SmartWallet.init(
  ///   chain: Chain.ethereum,
  ///   signer: myMultiSigner,
  ///   bundler: myBundler,
  /// );
  /// ```
  /// additionally initializes the associated Entrypoint contract for `tx.wait(userOpHash)` calls
  factory SmartWallet.init(
      {required Chain chain,
      required MultiSignerInterface signer,
      required BundlerProviderBase bundler}) {
    final instance =
        SmartWallet(chain: chain, signer: signer, bundler: bundler);

    instance.plugin('bundler').initializeWithEntrypoint(Entrypoint(
          address: chain.entrypoint,
          client: instance.plugin('factory').client,
        ));

    return instance;
  }

  @override
  EthereumAddress? get address => _walletAddress;

  @override
  Future<EtherAmount> get balance =>
      plugin<Contract>("contract").getBalance(_walletAddress);

  @override
  Future<bool> get deployed =>
      plugin<Contract>("contract").deployed(_walletAddress);

  @override
  String get initCode => _initCode;

  @override
  Future<BigInt> get initCodeGas => _initCodeGas;

  @override
  Future<Uint256> get nonce => _getNonce();

  @override
  @Deprecated(
      "pass the wallet address alongside the constructor if known beforehand")
  set setWalletAddress(EthereumAddress address) => _walletAddress = address;

  @override
  String? get toHex => _walletAddress?.hexEip55;

  String get _initCode => _initCalldata != null
      ? _chain.accountFactory!.hexEip55 + hexlify(_initCalldata!).substring(2)
      : "0x";

  Uint8List get _initCodeBytes {
    if (_initCalldata == null) return Uint8List(0);
    List<int> extended = _chain.accountFactory!.addressBytes.toList();
    extended.addAll(_initCalldata!);
    return Uint8List.fromList(extended);
  }

  Future<BigInt> get _initCodeGas => plugin<RPCProviderBase>('ethRpc')
      .estimateGas(_chain.entrypoint, _initCode);

  @override
  Future<SmartWallet> createSimpleAccount(Uint256 salt, {int? index}) async {
    EthereumAddress signer = EthereumAddress.fromHex(
        plugin<MultiSignerInterface>('signer').getAddress(index: index ?? 0));
    _initCalldata = _getInitCallData('createAccount', [signer, salt.value]);
    await getSimpleAccountAddress(signer, salt)
        .then((addr) => {_walletAddress = addr});
    return this;
  }

  @override
  Future<SmartWallet> createSimplePasskeyAccount(
      PassKeyPair pkp, Uint256 salt) async {
    _initCalldata = _getInitCallData('createPasskeyAccount', [
      pkp.credentialHexBytes,
      pkp.publicKey[0].value,
      pkp.publicKey[1].value,
      salt.value
    ]);

    await getSimplePassKeyAccountAddress(pkp, salt)
        .then((addr) => {_walletAddress = addr});
    return this;
  }

  @override
  void dangerouslySetInitCallData(Uint8List? code) {
    _initCalldata = code;
  }

  @override
  Future<EthereumAddress> getSimpleAccountAddress(
          EthereumAddress signer, Uint256 salt) =>
      plugin<_AccountFactory>('factory').getAddress(signer, salt.value);

  @override
  Future<EthereumAddress> getSimplePassKeyAccountAddress(
          PassKeyPair pkp, Uint256 salt) =>
      plugin<_AccountFactory>('factory').getPasskeyAccountAddress(
          pkp.credentialHexBytes,
          pkp.publicKey[0].value,
          pkp.publicKey[1].value,
          salt.value);

  @override
  UserOperation buildUserOperation({
    required Uint8List callData,
    BigInt? customNonce,
    BigInt? callGasLimit,
    BigInt? verificationGasLimit,
    BigInt? preVerificationGas,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
  }) =>
      UserOperation.partial(
        callData: callData,
        initCode: _initCodeBytes,
        sender: _walletAddress,
        nonce: customNonce,
        callGasLimit: callGasLimit,
        verificationGasLimit: verificationGasLimit,
        preVerificationGas: preVerificationGas,
        maxFeePerGas: maxFeePerGas,
        maxPriorityFeePerGas: maxPriorityFeePerGas,
      );

  @override
  Future<UserOperationResponse> send(
          EthereumAddress recipient, EtherAmount amount) =>
      sendUserOperation(buildUserOperation(
          callData:
              Contract.execute(_walletAddress, to: recipient, amount: amount)));

  @override
  Future<UserOperationResponse> sendTransaction(
          EthereumAddress to, Uint8List encodedFunctionData,
          {EtherAmount? amount}) =>
      sendUserOperation(buildUserOperation(
          callData: Contract.execute(_walletAddress,
              to: to, amount: amount, innerCallData: encodedFunctionData)));

  @override
  Future<UserOperationResponse> sendBatchedTransaction(
          List<EthereumAddress> recipients, List<Uint8List> calls,
          {List<EtherAmount>? amounts}) =>
      sendUserOperation(buildUserOperation(
          callData: Contract.executeBatch(
              walletAddress: _walletAddress,
              recipients: recipients,
              amounts: amounts,
              innerCalls: calls)));

  @override
  Future<UserOperationResponse> sendSignedUserOperation(UserOperation op) =>
      plugin<BundlerProviderBase>('bundler')
          .sendUserOperation(op.toMap(), _chain.entrypoint)
          .catchError(
              (e) => throw SmartWalletError.sendError(op, e.toString()));

  @override
  Future<UserOperationResponse> sendUserOperation(UserOperation op,
          {String? id}) =>
      signUserOperation(op, id: id)
          .then(sendSignedUserOperation)
          .catchError((e) => retryOp(() => sendSignedUserOperation(op), e));

  @override
  Future<UserOperation> signUserOperation(UserOperation userOp,
      {bool update = true, String? id, int? index}) async {
    if (update) userOp = await _updateUserOperation(userOp);

    final opHash = userOp.hash(_chain);

    Uint8List signature = await plugin<MultiSignerInterface>('signer')
        .personalSign(
            opHash,
            index: index,
            id: id ??
                (plugin('signer') is PasskeyInterface
                    ? plugin('signer').defaultId
                    : id));

    userOp.signature = hexlify(signature);

    await _validateUserOperation(userOp);
    return userOp;
  }

  Uint8List _getInitCallData(String functionName, List params) =>
      plugin<_AccountFactory>('factory')
          .self
          .function(functionName)
          .encodeCall(params);

  Future<Uint256> _getNonce() => _deployed == false
      ? Future.value(Uint256.zero)
      : plugin<Contract>("contract")
          .call(_chain.entrypoint, ContractAbis.get('getNonce'), "getNonce",
              params: [_walletAddress, BigInt.zero])
          .then((value) => Uint256(value[0]))
          .catchError((e) =>
              throw SmartWalletError.nonceError(_walletAddress, e.toString()));

  Future<UserOperation> _updateUserOperation(UserOperation op) async {
    List<dynamic> responses = await Future.wait([
      Future.microtask(() async => _deployed == null || _deployed == false
          ? _deployed = await deployed
          : _deployed),
      plugin<RPCProviderBase>('ethRpc').getGasPrice(),
      _getNonce()
    ]);

    op = op.copyWith(
        sender: _walletAddress,
        nonce: responses[2].value,
        initCode: responses[0] ? Uint8List(0) : null);
    op.signature = plugin<MultiSignerInterface>('signer').dummySignature;

    return plugin<BundlerProviderBase>('bundler')
        .estimateUserOperationGas(op.toMap(), _chain.entrypoint)
        .then((opGas) => op.updateOpGas(opGas, responses[1]))
        .then((op) => multiply(op))
        .catchError(
            (e) => throw SmartWalletError.estimateError(op, e.toString()));
  }

  Future _validateUserOperation(UserOperation op) async {
    if (_walletAddress == null) {
      throw SmartWalletError(
        'Wallet address not set',
      );
    }
    require(op.sender.hex == _walletAddress?.hex, "invalid sender address.");
    require(
        (_deployed ?? (await deployed))
            ? hexlify(op.initCode).toLowerCase() == "0x"
            : hexlify(op.initCode).toLowerCase() == initCode.toLowerCase(),
        "InitCode mismatch");
    require(op.callData.length >= 4, "Calldata too short");
    require(op.signature.length >= 64, "Signature too short");
  }
}

class SmartWalletError extends Error {
  final String message;

  SmartWalletError(this.message);

  factory SmartWalletError.estimateError(UserOperation op, String message) {
    return SmartWalletError('''
        Error estimating user operation gas! Failed with error: $message
        --------------------------------------------------
       User operation: ${op.toJson()}.
    ''');
  }

  factory SmartWalletError.nonceError(
      EthereumAddress? address, String message) {
    return SmartWalletError('''
        Error fetching user account nonce for address  ${address?.hex}! 
        --------------------------------------------------
        Failed with error: $message  
      ''');
  }

  factory SmartWalletError.sendError(UserOperation op, String message) {
    return SmartWalletError('''
        Error sending user operation! Failed with error: $message
        --------------------------------------------------
       User operation: ${op.toJson()}. 
    ''');
  }

  @override
  String toString() {
    return message;
  }
}
