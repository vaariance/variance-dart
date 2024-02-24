part of '../../variance.dart';

class SmartWallet with _PluginManager, _GasSettings implements SmartWalletBase {
  final Chain _chain;

  EthereumAddress? _walletAddress;

  Uint8List? _initCalldata;

  SmartWallet(
      {required Chain chain,
      required MultiSignerInterface signer,
      @Deprecated(
          "Bundler instance will be constructed by by factory from chain params")
      required BundlerProviderBase bundler,
      @Deprecated("to be removed: address will be made final in the future")
      EthereumAddress? address})
      : _chain = chain.validate(),
        _walletAddress = address {
    // since the wallet factory will use builder pattern to add plugins
    // the following can be moved into the factory.
    // which would allow the smartwallet to reamin testable.
    final ethRpc = RPCProvider(chain.ethRpcUrl!);
    final bundlerRpc = RPCProvider(chain.bundlerUrl!);

    final bundler = BundlerProvider(chain, bundlerRpc);
    final fact = _AccountFactory(
        address: chain.accountFactory!, chainId: chain.chainId, rpc: ethRpc);

    addPlugin('signer', signer);
    addPlugin('bundler', bundler);
    addPlugin('ethRpc', ethRpc);
    addPlugin('contract', Contract(ethRpc));
    addPlugin('factory', fact);

    if (chain.paymasterUrl != null) {
      final paymasterRpc = RPCProvider(chain.paymasterUrl!);
      final paymaster = Paymaster(chain, paymasterRpc);
      addPlugin('paymaster', paymaster);
    }
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
  ///   address: myWalletAddress,
  ///   initCallData: Uint8List.fromList([0x01, 0x02, 0x03]),
  /// );
  /// ```
  factory SmartWallet.init(
      {required Chain chain,
      required MultiSignerInterface signer,
      @Deprecated(
          "Bundler instance will be constructed by by factory from chain params")
      required BundlerProviderBase bundler,
      @Deprecated("address will be made final in the future")
      EthereumAddress? address,
      @Deprecated("seperation of factory from wallet soon will be enforced")
      Uint8List? initCallData}) {
    final instance = SmartWallet(
        chain: chain, signer: signer, bundler: bundler, address: address);
    return instance;
  }

  @override
  EthereumAddress? get address => _walletAddress;

  @override
  Future<EtherAmount> get balance =>
      plugin("contract").getBalance(_walletAddress);

  @override
  Future<bool> get isDeployed => plugin("contract").deployed(_walletAddress);

  @override
  String get initCode => _initCode;

  @override
  Future<BigInt> get initCodeGas => _initCodeGas;

  @override
  Future<Uint256> get nonce => _getNonce();

  @override
  @Deprecated("wallet address will be made final in the future")
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

  Future<BigInt> get _initCodeGas =>
      plugin('ethRpc').estimateGas(_chain.entrypoint, _initCode);

  @override
  Future<SmartWallet> createSimpleAccount(Uint256 salt, {int? index}) async {
    EthereumAddress signer =
        EthereumAddress.fromHex(plugin('signer').getAddress(index: index ?? 0));
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
      plugin('factory').getAddress(signer, salt.value);

  @override
  Future<EthereumAddress> getSimplePassKeyAccountAddress(
          PassKeyPair pkp, Uint256 salt) =>
      plugin('factory').getPasskeyAccountAddress(pkp.credentialHexBytes,
          pkp.publicKey[0].value, pkp.publicKey[1].value, salt.value);

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
      plugin('bundler')
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

    if (hasPlugin('paymaster')) {
      userOp = await plugin<Paymaster>().intercept(userOp);
    }

    Uint8List signature = await plugin('signer').personalSign(opHash,
        index: index,
        id: id ??
            (plugin('signer') is PasskeyInterface
                ? plugin('signer').defaultId
                : id));

    userOp.signature = hexlify(signature);
    userOp.validate(userOp.nonce > BigInt.zero, initCode);

    return userOp;
  }

  Uint8List _getInitCallData(String functionName, List params) =>
      plugin('factory').self.function(functionName).encodeCall(params);

  Future<Uint256> _getNonce() => isDeployed.then((deployed) => !deployed
      ? Future.value(Uint256.zero)
      : plugin("contract")
          .call(_chain.entrypoint, ContractAbis.get('getNonce'), "getNonce",
              params: [_walletAddress, BigInt.zero])
          .then((value) => Uint256(value[0]))
          .catchError((e) =>
              throw SmartWalletError.nonceError(_walletAddress, e.toString())));

  Future<UserOperation> _updateUserOperation(UserOperation op) =>
      Future.wait<dynamic>([_getNonce(), plugin('ethRpc').getGasPrice()])
          .then((responses) {
        op = op.copyWith(
            nonce: op.nonce > BigInt.zero ? op.nonce : responses[0].value,
            initCode: responses[0] > BigInt.zero ? Uint8List(0) : null,
            signature: plugin('signer').dummySignature);
        return _updateUserOperationGas(op, feePerGas: responses[1]);
      });

  Future<UserOperation> _updateUserOperationGas(UserOperation op,
          {Map<String, EtherAmount>? feePerGas}) =>
      plugin('bundler')
          .estimateUserOperationGas(op.toMap(), _chain.entrypoint)
          .then((opGas) => op.updateOpGas(opGas, feePerGas))
          .then((op) => multiply(op))
          .catchError(
              (e) => throw SmartWalletError.estimateError(op, e.toString()));
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
