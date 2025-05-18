part of '../../variance_dart.dart';

/// A factory class for creating various types of Ethereum smart wallets.
class SmartWalletFactory implements SmartWalletFactoryBase {
  final Chain _chain;
  final MSI _signer;
  final RPCBase _jsonRpc;
  final RPCBase _bundler;
  final RPCBase? _paymaster;

  /// Creates a new instance of the [SmartWalletFactory] class.
  ///
  /// [_chain] is the Ethereum chain configuration.
  /// [_signer] is the signer instance used for signing transactions.
  ///
  /// Throws an [InvalidFactoryAddress] exception if the provided chain does not
  /// have a valid account factory address.
  SmartWalletFactory(this._chain, this._signer)
    : assert(
        _chain.accountFactory != null,
        InvalidFactoryAddress(_chain.accountFactory),
      ),
      assert(_chain.jsonRpcUrl.isURL(), InvalidJsonRpcUrl(_chain.jsonRpcUrl)),
      assert(_chain.bundlerUrl.isURL(), InvalidBundlerUrl(_chain.bundlerUrl)),
      assert(
        _chain.paymasterUrl != null && _chain.paymasterUrl.isURL(),
        InvalidPaymasterUrl(_chain.paymasterUrl),
      ),
      _jsonRpc = RPCBase(_chain.jsonRpcUrl!),
      _bundler = RPCBase(_chain.bundlerUrl!),
      _paymaster =
          _chain.paymasterUrl != null ? RPCBase(_chain.paymasterUrl!) : null;

  /// A getter for the LightAccountFactory contract instance.
  _LightAccountFactory get _lightAccountfactory => _LightAccountFactory(
    address: _chain.accountFactory!,
    chainId: _chain.chainId,
    rpc: _jsonRpc,
  );

  /// A getter for the SafeProxyFactory contract instance.
  _SafeProxyFactory get _safeProxyFactory => _SafeProxyFactory(
    address: _chain.accountFactory!,
    chainId: _chain.chainId,
    rpc: _jsonRpc,
  );

  @override
  Future<SmartWallet> createAlchemyLightAccount(Uint256 salt) async {
    final signer = EthereumAddress.fromHex(_signer.getAddress());

    final address = await _lightAccountfactory.getAddress((
      owner: signer,
      salt: salt.value,
    ));

    final initCalldata = _lightAccountfactory.self
        .function('createAccount')
        .encodeCall([signer, salt.value]);

    final initCode = _getInitCode(initCalldata);
    return _createAccount(address, initCode);
  }

  @override
  Future<SmartWallet> createSafe7579Account(
    Uint256 salt,
    EthereumAddress launchpad, {
    SafeSingletonAddress? singleton,
    Iterable<ModuleInit<EthereumAddress, Uint8List>>? validators,
    Iterable<ModuleInit<EthereumAddress, Uint8List>>? executors,
    Iterable<ModuleInit<EthereumAddress, Uint8List>>? fallbacks,
    Iterable<ModuleInit<EthereumAddress, Uint8List>>? hooks,
    Iterable<EthereumAddress>? attesters,
    int? attestersThreshold,
  }) async {
    final signer = EthereumAddress.fromHex(_signer.getAddress());
    final module = Safe4337ModuleAddress.fromVersion(
      _chain.entrypoint.version,
      isSafe7579: true,
    );

    singleton =
        _chain.chainId == 1
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

    return _createSafeAccount(salt, initializer, initializer.launchpad);
  }

  @override
  Future<SmartWallet> createSafe7579AccountWithPasskey(
    PassKeyPair keyPair,
    Uint256 salt,
    EthereumAddress launchpad, {
    EthereumAddress? p256Verifier,
    SafeSingletonAddress? singleton,
    Iterable<ModuleInit<EthereumAddress, Uint8List>>? validators,
    Iterable<ModuleInit<EthereumAddress, Uint8List>>? executors,
    Iterable<ModuleInit<EthereumAddress, Uint8List>>? fallbacks,
    Iterable<ModuleInit<EthereumAddress, Uint8List>>? hooks,
    Iterable<EthereumAddress>? attesters,
    int? attestersThreshold,
  }) async {
    final module = Safe4337ModuleAddress.fromVersion(
      _chain.entrypoint.version,
      isSafe7579: true,
    );
    final verifier = p256Verifier ?? Addresses.p256VerifierAddress;

    singleton =
        _chain.chainId == 1
            ? SafeSingletonAddress.l1
            : singleton ?? SafeSingletonAddress.l2;

    encodeWebAuthnConfigure() {
      return Contract.encodeFunctionCall(
        "configure",
        Addresses.sharedSignerAddress,
        ContractAbis.get("enableWebauthn"),
        [
          [
            keyPair.authData.publicKey.item1.value,
            keyPair.authData.publicKey.item2.value,
            hexToInt(verifier.hexNo0x.padLeft(44, '0')),
          ],
        ],
      );
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

    return _createSafeAccount(salt, initializer, initializer.launchpad);
  }

  @override
  Future<SmartWallet> createSafeAccount(
    Uint256 salt, [
    SafeSingletonAddress? singleton,
  ]) {
    final signer = EthereumAddress.fromHex(_signer.getAddress());
    final module = Safe4337ModuleAddress.fromVersion(_chain.entrypoint.version);

    singleton =
        _chain.chainId == 1
            ? SafeSingletonAddress.l1
            : singleton ?? SafeSingletonAddress.l2;

    final initializer = _SafeInitializer(
      owners: [signer],
      threshold: 1,
      module: module,
      singleton: singleton,
    );

    return _createSafeAccount(salt, initializer, singleton.address);
  }

  @override
  Future<SmartWallet> createSafeAccountWithPasskey(
    PassKeyPair keyPair,
    Uint256 salt, {
    EthereumAddress? p256Verifier,
    SafeSingletonAddress? singleton,
  }) {
    final module = Safe4337ModuleAddress.fromVersion(_chain.entrypoint.version);
    final verifier = p256Verifier ?? Addresses.p256VerifierAddress;
    final safe = _getSafe();

    encodeWebAuthnConfigure() {
      return Contract.encodeFunctionCall(
        "configure",
        Addresses.sharedSignerAddress,
        ContractAbis.get("enableWebauthn"),
        [
          [
            keyPair.authData.publicKey.item1.value,
            keyPair.authData.publicKey.item2.value,
            hexToInt(verifier.hexNo0x.padLeft(44, '0')),
          ],
        ],
      );
    }

    encodeWebauthnSetup(Uint8List Function() encodeModuleSetup) {
      return safe.$2!.getSafeMultisendCallData(
        [module.setup, Addresses.sharedSignerAddress],
        null,
        [encodeModuleSetup(), encodeWebAuthnConfigure()],
        [intToBytes(BigInt.one), intToBytes(BigInt.one)],
      );
    }

    singleton =
        _chain.chainId == 1
            ? SafeSingletonAddress.l1
            : singleton ?? SafeSingletonAddress.l2;

    final initializer = _SafeInitializer(
      owners: [Addresses.sharedSignerAddress],
      threshold: 1,
      module: module,
      singleton: singleton,
      encodeWebauthnSetup: encodeWebauthnSetup,
    );

    return _createSafeAccount(salt, initializer, singleton.address);
  }

  @override
  @Deprecated("Use default account standards")
  Future<SmartWallet> createVendorAccount(
    EthereumAddress address,
    Uint8List initCode,
  ) async {
    return _createAccount(address, initCode);
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
    EthereumAddress address,
    Uint8List initCode, [
    _SafeInitializer? initializer,
  ]) {
    final safe = _getSafe(initializer);
    final SmartWalletState state = SmartWalletState(
      chain: _chain,
      address: address,
      signer: _signer,
      initCode: initCode,
      jsonRpc: _jsonRpc,
      bundler: _bundler,
      paymaster: _paymaster,
      safe: safe.$1,
    );
    final wallet = SmartWallet(state);
    return wallet;
  }

  Future<SmartWallet> _createSafeAccount(
    Uint256 salt,
    _SafeInitializer initializer,
    EthereumAddress singleton,
  ) async {
    final initializationData = initializer.getInitializer();
    final creation = await _safeProxyFactory.proxyCreationCode();

    final address = _safeProxyFactory.getPredictedSafe(
      initializationData,
      salt,
      creation,
      singleton,
    );

    final initCallData = _safeProxyFactory.self
        .function("createProxyWithNonce")
        .encodeCall([singleton, initializationData, salt.value]);

    final initCode = _getInitCode(initCallData);
    return _createAccount(address, initCode, initializer);
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

  (_Safe?, _SafeModule?) _getSafe([_SafeInitializer? initializer]) {
    final isSafe7579 = initializer is _Safe7579Initializer;
    _SafeModule safeModule = _SafeModule(
      address:
          Safe4337ModuleAddress.fromVersion(
            _chain.entrypoint.version,
            isSafe7579: isSafe7579,
          ).address,
      chainId: _chain.chainId,
      client: _safeProxyFactory.client,
    );
    if (initializer == null) return (null, safeModule);
    return (
      _Safe(
        isSafe7579: isSafe7579,
        module: safeModule,
        initializer: initializer,
      ),
      null,
    );
  }
}
