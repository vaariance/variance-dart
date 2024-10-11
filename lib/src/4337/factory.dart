part of '../../variance_dart.dart';

/// A factory class for creating various types of Ethereum smart wallets.
class SmartWalletFactory implements SmartWalletFactoryBase {
  final Chain _chain;
  final MSI _signer;

  late final JsonRPCProvider _jsonRpc;
  late final BundlerProvider _bundler;
  late final Contract _contract;

  /// Creates a new instance of the [SmartWalletFactory] class.
  ///
  /// [_chain] is the Ethereum chain configuration.
  /// [_signer] is the signer instance used for signing transactions.
  ///
  /// Throws an [InvalidFactoryAddress] exception if the provided chain does not
  /// have a valid account factory address.
  SmartWalletFactory(this._chain, this._signer)
      : assert(_chain.accountFactory != null,
            InvalidFactoryAddress(_chain.accountFactory)),
        _jsonRpc = JsonRPCProvider(_chain),
        _bundler = BundlerProvider(_chain) {
    _contract = Contract(_jsonRpc.rpc);
  }

  /// A getter for the SafePlugin instance.
  _SafePlugin get _safePlugin => _SafePlugin(
      address:
          Safe4337ModuleAddress.fromVersion(_chain.entrypoint.version).address,
      chainId: _chain.chainId,
      client: _safeProxyFactory.client);

  /// A getter for the SafeProxyFactory contract instance.
  _SafeProxyFactory get _safeProxyFactory => _SafeProxyFactory(
      address: _chain.accountFactory!,
      chainId: _chain.chainId,
      rpc: _jsonRpc.rpc);

  /// A getter for the LightAccountFactory contract instance.
  _LightAccountFactory get _lightAccountfactory => _LightAccountFactory(
      address: _chain.accountFactory!,
      chainId: _chain.chainId,
      rpc: _jsonRpc.rpc);

  @override
  Future<SmartWallet> createSafeAccountWithPasskey(PassKeyPair keyPair,
      Uint256 salt, EthereumAddress safeWebauthnSharedSigner,
      [EthereumAddress? p256Verifier]) {
    final module = Safe4337ModuleAddress.fromVersion(_chain.entrypoint.version);
    final verifier = p256Verifier ?? Constants.p256VerifierAddress;

    encodeWebAuthnConfigure() {
      return Contract.encodeFunctionCall("configure", safeWebauthnSharedSigner,
          ContractAbis.get("enableWebauthn"), [
        [
          keyPair.authData.publicKey.item1.value,
          keyPair.authData.publicKey.item2.value,
          hexToInt(verifier.hexNo0x.padLeft(44, '0')),
        ]
      ]);
    }

    encodeWebauthnSetup(Uint8List Function() encodeModuleSetup) {
      return _safePlugin.getSafeMultisendCallData(
          [module.setup, safeWebauthnSharedSigner],
          null,
          [encodeModuleSetup(), encodeWebAuthnConfigure()],
          [intToBytes(BigInt.one), intToBytes(BigInt.one)]);
    }

    return _createSafeAccount(
        salt, safeWebauthnSharedSigner, module, encodeWebauthnSetup);
  }

  @override
  Future<SmartWallet> createSafeAccount(Uint256 salt) {
    final signer = EthereumAddress.fromHex(_signer.getAddress());
    final module = Safe4337ModuleAddress.fromVersion(_chain.entrypoint.version);

    return _createSafeAccount(salt, signer, module);
  }

  @override
  Future<SmartWallet> createAlchemyLightAccount(Uint256 salt,
      [int? index]) async {
    final signer =
        EthereumAddress.fromHex(_signer.getAddress(index: index ?? 0));

    // Get the predicted address of the light account
    final address = await _lightAccountfactory
        .getAddress((owner: signer, salt: salt.value));

    // Encode the call data for the `createAccount` function
    // This function is used to create the light account with the given signer address and salt
    final initCalldata = _lightAccountfactory.self
        .function('createAccount')
        .encodeCall([signer, salt.value]);

    // Generate the initialization code by combining the account factory address and the encoded call data
    final initCode = _getInitCode(initCalldata);

    // Create the SmartWallet instance for the light account
    return _createAccount(_chain, address, initCode);
  }

  @override
  Future<SmartWallet> createVendorAccount(
    EthereumAddress address,
    Uint8List initCode,
  ) async {
    return _createAccount(_chain, address, initCode);
  }

  Future<SmartWallet> _createSafeAccount(
      Uint256 salt, EthereumAddress signer, Safe4337ModuleAddress module,
      [Uint8List Function(Uint8List Function())? setup]) async {
    final singleton = _chain.chainId == 1
        ? Constants.safeSingletonAddress
        : Constants.safeL2SingletonAddress;

    // Get the initializer data for the Safe account
    final initializer =
        _safeProxyFactory.getInitializer([signer], 1, module, setup);

    // Get the proxy creation code for the Safe account
    final creation = await _safeProxyFactory.proxyCreationCode();

    // Predict the address of the Safe account
    final address = _safeProxyFactory.getPredictedSafe(
        initializer, salt, creation, singleton);

    // Encode the call data for the `createProxyWithNonce` function
    // This function is used to create the Safe account with the given initializer data and salt
    final initCallData = _safeProxyFactory.self
        .function("createProxyWithNonce")
        .encodeCall([singleton, initializer, salt.value]);

    // Generate the initialization code by combining the account factory address and the encoded call data
    final initCode = _getInitCode(initCallData);

    // Create the SmartWallet instance for the Safe account
    return _createAccount(_chain, address, initCode)
      ..addPlugin<_SafePlugin>('safe', _safePlugin);
  }

  /// Creates a new [SmartWallet] instance with the provided chain, address, and initialization code.
  ///
  /// [chain] is the Ethereum chain configuration.
  /// [address] is the Ethereum address of the account.
  /// [initCalldata] is the initialization code for the account.
  ///
  /// The [SmartWallet] instance is created with various plugins added to it, including:
  /// - [MSI] signer plugin
  /// - [BundlerProviderBase] bundler plugin
  /// - [JsonRPCProviderBase] JSON-RPC provider plugin
  /// - [Contract] contract plugin
  ///
  /// Returns a [SmartWallet] instance representing the created account.
  SmartWallet _createAccount(
    Chain chain,
    EthereumAddress address,
    Uint8List initCalldata,
  ) {
    final wallet = SmartWallet(chain, address, initCalldata)
      ..addPlugin<MSI>('signer', _signer)
      ..addPlugin<BundlerProviderBase>('bundler', _bundler)
      ..addPlugin<JsonRPCProviderBase>('jsonRpc', _jsonRpc)
      ..addPlugin<Contract>('contract', _contract);

    if (chain.paymasterUrl != null) {
      wallet.addPlugin<PaymasterBase>('paymaster', Paymaster(chain));
    }

    return wallet;
  }

  /// Returns the initialization code for the account by concatenating the account factory address with the provided initialization call data.
  ///
  /// [initCalldata] is the initialization call data for the account.
  ///
  /// The initialization code is required to create the account on the client-side. It is generated by combining the account factory address and the encoded call data for the account creation function.
  ///
  /// Returns a [Uint8List] containing the initialization code.
  Uint8List _getInitCode(Uint8List initCalldata) {
    List<int> extended = _chain.accountFactory!.addressBytes.toList();
    extended.addAll(initCalldata);
    return Uint8List.fromList(extended);
  }
}
