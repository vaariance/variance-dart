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

  /// A getter for the P256AccountFactory contract instance.
  _P256AccountFactory get _p256Accountfactory => _P256AccountFactory(
      address: _chain.accountFactory!,
      chainId: _chain.chainId,
      rpc: _jsonRpc.rpc);

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
  Future<SmartWallet> createP256Account<T>(T keyPair, Uint256 salt,
      [EthereumAddress? recoveryAddress]) {
    switch (keyPair.runtimeType) {
      case const (PassKeyPair):
        return _createPasskeyAccount(
            keyPair as PassKeyPair, salt, recoveryAddress);
      case const (P256Credential):
        return _createSecureEnclaveAccount(
            keyPair as P256Credential, salt, recoveryAddress);
      default:
        throw ArgumentError.value(keyPair, 'keyPair',
            'createP256Account: An instance of `PassKeyPair` or `P256Credential` is expected, but got: ${keyPair.runtimeType}');
    }
  }

  @override
  Future<SmartWallet> createSafeAccount(Uint256 salt) async {
    final signer = EthereumAddress.fromHex(_signer.getAddress());

    // Get the initializer data for the Safe account
    final initializer = _safeProxyFactory.getInitializer([signer], 1,
        Safe4337ModuleAddress.fromVersion(_chain.entrypoint.version));

    // Get the proxy creation code for the Safe account
    final creation = await _safeProxyFactory.proxyCreationCode();

    // Predict the address of the Safe account
    final address =
        _safeProxyFactory.getPredictedSafe(initializer, salt, creation);

    // Encode the call data for the `createProxyWithNonce` function
    // This function is used to create the Safe account with the given initializer data and salt
    final initCallData = _safeProxyFactory.self
        .function("createProxyWithNonce")
        .encodeCall([Constants.safeSingletonAddress, initializer, salt.value]);

    // Generate the initialization code by combining the account factory address and the encoded call data
    final initCode = _getInitCode(initCallData);

    // Create the SmartWallet instance for the Safe account
    return _createAccount(_chain, address, initCode)
      ..addPlugin<_SafePlugin>('safe', _safePlugin);
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
    return _createAccount(
        _chain, address, initCode, Constants.defaultBytePrefix);
  }

  @override
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
      [Uint8List? prefix]) {
    final wallet = SmartWallet(chain, address, initCalldata, prefix)
      ..addPlugin<MSI>('signer', _signer)
      ..addPlugin<BundlerProviderBase>('bundler', _bundler)
      ..addPlugin<JsonRPCProviderBase>('jsonRpc', _jsonRpc)
      ..addPlugin<Contract>('contract', _contract);

    if (chain.paymasterUrl != null) {
      wallet.addPlugin<PaymasterBase>('paymaster', Paymaster(chain));
    }

    return wallet;
  }

  /// Creates a new passkey account with the provided [PassKeyPair], salt, and optional recovery address.
  ///
  /// [pkp] is the [PassKeyPair] instance used to create the account.
  /// [salt] is the salt value used in the account creation process.
  /// [recoveryAddress] is an optional recovery address for the account.
  ///
  /// Returns a [Future] that resolves to a [SmartWallet] instance representing
  /// the created passkey account.
  ///
  /// The process involves:
  /// 1. Encoding the account creation data with the provided [PassKeyPair], [salt], and [recoveryAddress].
  ///    - The encoded data includes the recovery address, credential hex, and public key components.
  /// 2. Calling the `createP256Account` function on the `_p256AccountFactory` contract with the encoded data and [salt].
  ///    - This function initiates the account creation process on the Ethereum blockchain.
  /// 3. Getting the initialization code by combining the account factory address and the encoded call data.
  ///    - The initialization code is required to create the account on the client-side.
  /// 4. Predicting the account address using the `_p256AccountFactory` contract's `getP256AccountAddress` function.
  ///    - This function predicts the address of the account based on the creation data and salt.
  /// 5. Creating a new [SmartWallet] instance with the predicted address and initialization code.
  Future<SmartWallet> _createPasskeyAccount(PassKeyPair pkp, Uint256 salt,
      [EthereumAddress? recoveryAddress]) async {
    final Uint8List creation = abi.encode([
      'address',
      'bytes32',
      'uint256',
      'uint256'
    ], [
      recoveryAddress ?? Constants.zeroAddress,
      hexToBytes(pkp.authData.hexCredential),
      pkp.authData.publicKey.item1.value,
      pkp.authData.publicKey.item2.value,
    ]);

    final initCalldata = _p256Accountfactory.self
        .function('createP256Account')
        .encodeCall([salt.value, creation]);
    final initCode = _getInitCode(initCalldata);
    final address = await _p256Accountfactory
        .getP256AccountAddress((salt: salt.value, creation: creation));
    return _createAccount(_chain, address, initCode);
  }

  /// Creates a new secure enclave account with the provided [P256Credential], salt, and optional recovery address.
  ///
  /// [p256] is the [P256Credential] instance used to create the account.
  /// [salt] is the salt value used in the account creation process.
  /// [recoveryAddress] is an optional recovery address for the account.
  ///
  /// Returns a [Future] that resolves to a [SmartWallet] instance representing
  /// the created secure enclave account.
  ///
  /// The process is similar to [_createPasskeyAccount] but with a different encoding for the account creation data.
  /// 1. Encoding the account creation data with the provided [P256Credential], [salt], and [recoveryAddress].
  ///    - The encoded data includes the recovery address, an empty bytes32 value, and the public key components.
  /// 2. Calling the `createP256Account` function on the `_p256AccountFactory` contract with the encoded data and [salt].
  /// 3. Getting the initialization code by combining the account factory address and the encoded call data.
  /// 4. Predicting the account address using the `_p256AccountFactory` contract's `getP256AccountAddress` function.
  /// 5. Creating a new [SmartWallet] instance with the predicted address and initialization code.
  Future<SmartWallet> _createSecureEnclaveAccount(
      P256Credential p256, Uint256 salt,
      [EthereumAddress? recoveryAddress]) async {
    final Uint8List creation = abi.encode([
      'address',
      'bytes32',
      'uint256',
      'uint256'
    ], [
      recoveryAddress ?? Constants.zeroAddress,
      Uint8List(32),
      p256.publicKey.item1.value,
      p256.publicKey.item2.value,
    ]);

    final initCalldata = _p256Accountfactory.self
        .function('createP256Account')
        .encodeCall([salt.value, creation]);
    final initCode = _getInitCode(initCalldata);
    final address = await _p256Accountfactory
        .getP256AccountAddress((salt: salt.value, creation: creation));
    return _createAccount(_chain, address, initCode);
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
