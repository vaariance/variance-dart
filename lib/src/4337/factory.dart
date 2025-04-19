part of '../../variance_dart.dart';

/// A factory class for creating various types of Ethereum smart wallets.
class SmartWalletFactory implements SmartWalletFactoryBase {
  final Chain _chain;
  final MSI _signer;
  final RPCBase _rpc;

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
        assert(_chain.jsonRpcUrl.isURL(), InvalidJsonRpcUrl(_chain.jsonRpcUrl)),
        _rpc = RPCBase(_chain.jsonRpcUrl!);

  /// A getter for the LightAccountFactory contract instance.
  _LightAccountFactory get _lightAccountfactory => _LightAccountFactory(
      address: _chain.accountFactory!, chainId: _chain.chainId, rpc: _rpc);

  /// A getter for the SafePlugin instance.
  _SafeModule _safeModule([bool safe7579 = false]) => _SafeModule(
      address: Safe4337ModuleAddress.fromVersion(_chain.entrypoint.version,
              safe7579: safe7579)
          .address,
      chainId: _chain.chainId,
      client: _safeProxyFactory.client);

  /// A getter for the SafeProxyFactory contract instance.
  _SafeProxyFactory get _safeProxyFactory => _SafeProxyFactory(
      address: _chain.accountFactory!, chainId: _chain.chainId, rpc: _rpc);

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
  Future<SmartWallet> createSafe7579Account(
      Uint256 salt, EthereumAddress launchpad,
      {SafeSingletonAddress? singleton,
      Iterable<ModuleInit<EthereumAddress, Uint8List>>? validators,
      Iterable<ModuleInit<EthereumAddress, Uint8List>>? executors,
      Iterable<ModuleInit<EthereumAddress, Uint8List>>? fallbacks,
      Iterable<ModuleInit<EthereumAddress, Uint8List>>? hooks,
      Iterable<EthereumAddress>? attesters,
      int? attestersThreshold}) async {
    final signer = EthereumAddress.fromHex(_signer.getAddress());
    final module = Safe4337ModuleAddress.fromVersion(_chain.entrypoint.version,
        safe7579: true);

    singleton = _chain.chainId == 1
        ? SafeSingletonAddress.l1
        : singleton ?? SafeSingletonAddress.l2;

    final initializer = _Safe7579Initializer(
      owners: [signer],
      threshold: 1,
      module: module,
      singleton: singleton,
      launchpad: launchpad,
      validators: validators,
      executors: executors,
      fallbacks: fallbacks,
      hooks: hooks,
      attesters: attesters,
      attestersThreshold: attestersThreshold,
      setupTo: Addresses.zeroAddress,
      setupData: Uint8List(0),
    );

    return _createSafeAccount(salt, initializer);
  }

  @override
  Future<SmartWallet> createSafe7579AccountWithPasskey(
      PassKeyPair keyPair, Uint256 salt, EthereumAddress launchpad,
      {EthereumAddress? p256Verifier,
      SafeSingletonAddress? singleton,
      Iterable<ModuleInit<EthereumAddress, Uint8List>>? validators,
      Iterable<ModuleInit<EthereumAddress, Uint8List>>? executors,
      Iterable<ModuleInit<EthereumAddress, Uint8List>>? fallbacks,
      Iterable<ModuleInit<EthereumAddress, Uint8List>>? hooks,
      Iterable<EthereumAddress>? attesters,
      int? attestersThreshold}) async {
    final module = Safe4337ModuleAddress.fromVersion(_chain.entrypoint.version,
        safe7579: true);
    final verifier = p256Verifier ?? Addresses.p256VerifierAddress;

    singleton = _chain.chainId == 1
        ? SafeSingletonAddress.l1
        : singleton ?? SafeSingletonAddress.l2;

    encodeWebAuthnConfigure() {
      return Contract.encodeFunctionCall("configure",
          Addresses.sharedSignerAddress, ContractAbis.get("enableWebauthn"), [
        [
          keyPair.authData.publicKey.item1.value,
          keyPair.authData.publicKey.item2.value,
          hexToInt(verifier.hexNo0x.padLeft(44, '0')),
        ]
      ]);
    }

    final initializer = _Safe7579Initializer(
      owners: [Addresses.sharedSignerAddress],
      threshold: 1,
      module: module,
      singleton: singleton,
      launchpad: launchpad,
      validators: validators,
      executors: executors,
      fallbacks: fallbacks,
      hooks: hooks,
      attesters: attesters,
      attestersThreshold: attestersThreshold,
      setupTo: Addresses.sharedSignerAddress,
      setupData: encodeWebAuthnConfigure(),
    );

    return _createSafeAccount(salt, initializer);
  }

  @override
  Future<SmartWallet> createSafeAccount(Uint256 salt,
      [SafeSingletonAddress? singleton]) {
    final signer = EthereumAddress.fromHex(_signer.getAddress());
    final module = Safe4337ModuleAddress.fromVersion(_chain.entrypoint.version);

    singleton = _chain.chainId == 1
        ? SafeSingletonAddress.l1
        : singleton ?? SafeSingletonAddress.l2;

    final initializer = _SafeInitializer(
      owners: [signer],
      threshold: 1,
      module: module,
      singleton: singleton,
    );

    return _createSafeAccount(salt, initializer);
  }

  @override
  Future<SmartWallet> createSafeAccountWithPasskey(
      PassKeyPair keyPair, Uint256 salt,
      {EthereumAddress? p256Verifier, SafeSingletonAddress? singleton}) {
    final module = Safe4337ModuleAddress.fromVersion(_chain.entrypoint.version);
    final verifier = p256Verifier ?? Addresses.p256VerifierAddress;

    encodeWebAuthnConfigure() {
      return Contract.encodeFunctionCall("configure",
          Addresses.sharedSignerAddress, ContractAbis.get("enableWebauthn"), [
        [
          keyPair.authData.publicKey.item1.value,
          keyPair.authData.publicKey.item2.value,
          hexToInt(verifier.hexNo0x.padLeft(44, '0')),
        ]
      ]);
    }

    encodeWebauthnSetup(Uint8List Function() encodeModuleSetup) {
      return _safeModule().getSafeMultisendCallData(
          [module.setup, Addresses.sharedSignerAddress],
          null,
          [encodeModuleSetup(), encodeWebAuthnConfigure()],
          [intToBytes(BigInt.one), intToBytes(BigInt.one)]);
    }

    singleton = _chain.chainId == 1
        ? SafeSingletonAddress.l1
        : singleton ?? SafeSingletonAddress.l2;

    final initializer = _SafeInitializer(
      owners: [Addresses.sharedSignerAddress],
      threshold: 1,
      module: module,
      singleton: singleton,
      encodeWebauthnSetup: encodeWebauthnSetup,
    );

    return _createSafeAccount(salt, initializer);
  }

  @override
  @Deprecated("Use default account standards")
  Future<SmartWallet> createVendorAccount(
    EthereumAddress address,
    Uint8List initCode,
  ) async {
    return _createAccount(_chain, address, initCode);
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
      Chain chain, EthereumAddress address, Uint8List initCalldata,
      [_SafeModule? safe, _SafeInitializer? initializer]) {
    final wallet = SmartWallet(chain, address, _signer, initCalldata)
      .._initialize(_rpc, safe, initializer);
    return wallet;
  }

  Future<SmartWallet> _createSafeAccount(
      Uint256 salt, _SafeInitializer initializer) async {
    final is7579 = initializer is _Safe7579Initializer;
    final singletonOrLaunchpad =
        is7579 ? initializer.launchpad : initializer.singleton.address;

    // Get the initializer data for the Safe account
    final initializationData = initializer.getInitializer();

    // Get the proxy creation code for the Safe account
    final creation = await _safeProxyFactory.proxyCreationCode();

    // Predict the address of the Safe account
    final address = _safeProxyFactory.getPredictedSafe(
        initializationData, salt, creation, singletonOrLaunchpad);

    // Encode the call data for the `createProxyWithNonce` function
    // This function is used to create the Safe account with the given initializer data and salt
    final initCallData = _safeProxyFactory.self
        .function("createProxyWithNonce")
        .encodeCall([singletonOrLaunchpad, initializationData, salt.value]);

    // Generate the initialization code by combining the account factory address and the encoded call data
    final initCode = _getInitCode(initCallData);

    // Create the SmartWallet instance for the Safe account
    return _createAccount(_chain, address, initCode, _safeModule(is7579),
        is7579 ? initializer : null);
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
