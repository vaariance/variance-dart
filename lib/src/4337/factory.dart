part of '../../variance.dart';

class SmartWalletFactory implements SmartWalletFactoryBase {
  final Chain _chain;
  final MSI _signer;

  late final JsonRPCProvider _jsonRpc;
  late final BundlerProvider _bundler;
  late final Contract _contract;

  SmartWalletFactory(this._chain, this._signer)
      : assert(_chain.accountFactory != null,
            InvalidFactoryAddress(_chain.accountFactory)),
        _jsonRpc = JsonRPCProvider(_chain),
        _bundler = BundlerProvider(_chain) {
    _contract = Contract(_jsonRpc.rpc);
  }

  _P256AccountFactory get _p256Accountfactory => _P256AccountFactory(
      address: _chain.accountFactory!,
      chainId: _chain.chainId,
      rpc: _jsonRpc.rpc);

  _SafeProxyFactory get _safeProxyFactory => _SafeProxyFactory(
      address: _chain.accountFactory!,
      chainId: _chain.chainId,
      rpc: _jsonRpc.rpc);

  _SimpleAccountFactory get _simpleAccountfactory => _SimpleAccountFactory(
      address: _chain.accountFactory!,
      chainId: _chain.chainId,
      rpc: _jsonRpc.rpc);

  _SafePlugin get _safePlugin => _SafePlugin(
      address:
          Safe4337ModuleAddress.fromVersion(_chain.entrypoint.version).address,
      chainId: _chain.chainId,
      client: _safeProxyFactory.client);

  Future<SmartWallet> createP256Account<T>(T keyPair, Uint256 salt,
      [EthereumAddress? recoveryAddress]) {
    switch (keyPair.runtimeType) {
      case PassKeyPair _:
        return _createPasskeyAccount(
            keyPair as PassKeyPair, salt, recoveryAddress);
      case P256Credential _:
        return _createSecureEnclaveAccount(
            keyPair as P256Credential, salt, recoveryAddress);
      default:
        throw ArgumentError.value(keyPair, 'keyPair',
            'createP256Account: An instance of `PassKeyPair` or `P256Credential` is expected');
    }
  }

  Future<SmartWallet> createSafeAccount(Uint256 salt,
      [List<EthereumAddress>? owners, int? threshold]) async {
    final signer = EthereumAddress.fromHex(_signer.getAddress());
    final ownerSet = owners != null ? {signer, ...owners} : [signer];
    final initializer = _safeProxyFactory.getInitializer(
        ownerSet,
        threshold ?? 1,
        Safe4337ModuleAddress.fromVersion(_chain.entrypoint.version));
    final creation = await _safeProxyFactory.proxyCreationCode();
    final address =
        _safeProxyFactory.getPredictedSafe(initializer, salt, creation);
    final initCallData = _safeProxyFactory.self
        .function("createProxyWithNonce")
        .encodeCall([Constants.safeSingletonAddress, initializer, salt.value]);
    final initCode = _getInitCode(initCallData);
    return _createAccount(_chain, address, initCode)
      ..addPlugin<_SafePlugin>('safe', _safePlugin);
  }

  Future<SmartWallet> createSimpleAccount(Uint256 salt, [int? index]) async {
    final signer = _signer.getAddress(index: index ?? 0);
    final address = await _simpleAccountfactory.getAddress(
        EthereumAddress.fromHex(signer), salt.value);
    final initCalldata = _simpleAccountfactory.self
        .function('createAccount')
        .encodeCall([signer, salt.value]);
    final initCode = _getInitCode(initCalldata);
    return _createAccount(_chain, address, initCode);
  }

  Future<SmartWallet> createVendorAccount(
    EthereumAddress address,
    Uint8List initCode,
  ) async {
    return _createAccount(_chain, address, initCode);
  }

  SmartWallet _createAccount(
      Chain chain, EthereumAddress address, Uint8List initCalldata) {
    return SmartWallet(chain, address, initCalldata)
      ..addPlugin<MSI>('signer', _signer)
      ..addPlugin<BundlerProviderBase>('bundler', _bundler)
      ..addPlugin<JsonRPCProviderBase>('jsonRpc', _jsonRpc)
      ..addPlugin<Contract>('contract', _contract);
  }

  Future<SmartWallet> _createPasskeyAccount(PassKeyPair pkp, Uint256 salt,
      [EthereumAddress? recoveryAddress]) async {
    final Uint8List creation = abi.encode([
      'address',
      'bytes32',
      'uint256',
      'uint256'
    ], [
      recoveryAddress ?? Constants.zeroAddress,
      hexToBytes(pkp.credentialHex),
      pkp.publicKey.item1.value,
      pkp.publicKey.item2.value,
    ]);

    final initCalldata = _p256Accountfactory.self
        .function('createP256Account')
        .encodeCall([creation, salt.value]);
    final initCode = _getInitCode(initCalldata);
    final address =
        await _p256Accountfactory.getP256AccountAddress(salt.value, creation);
    return _createAccount(_chain, address, initCode);
  }

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
      Uint8List(0),
      p256.publicKey.item1.value,
      p256.publicKey.item2.value,
    ]);

    final initCalldata = _p256Accountfactory.self
        .function('createP256Account')
        .encodeCall([creation, salt.value]);
    final initCode = _getInitCode(initCalldata);
    final address =
        await _p256Accountfactory.getP256AccountAddress(salt.value, creation);
    return _createAccount(_chain, address, initCode);
  }

  Uint8List _getInitCode(Uint8List initCalldata) {
    List<int> extended = _chain.accountFactory!.addressBytes.toList();
    extended.addAll(initCalldata);
    return Uint8List.fromList(extended);
  }
}
