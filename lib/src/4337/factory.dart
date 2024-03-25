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

  _SimpleAccountFactory get _simpleAccountfactory => _SimpleAccountFactory(
      address: _chain.accountFactory!,
      chainId: _chain.chainId,
      rpc: _jsonRpc.rpc);

  _P256AccountFactory get _p256Accountfactory => _P256AccountFactory(
      address: _chain.accountFactory!,
      chainId: _chain.chainId,
      rpc: _jsonRpc.rpc);

  // SafeAccountFactory

  Future<SmartWallet> createSimpleAccount(Uint256 salt, {int? index}) async {
    final signer = _signer.getAddress(index: index ?? 0);
    final address = await _simpleAccountfactory.getAddress(
        EthereumAddress.fromHex(signer), salt.value);
    final initCode = _getInitCode('createAccount', [signer, salt.value]);
    return _createAccount(_chain, address, initCode);
  }

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

  Future<SmartWallet> createSafeAccount() {
    // TODO: implement createSafeAccount
    throw UnimplementedError();
  }

  Future<SmartWallet> createVendorAccount(
    EthereumAddress address,
    Uint8List initCode,
  ) async {
    return _createAccount(_chain, address, initCode);
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

    final initCode = _getInitCode('createP256Account', [creation, salt.value]);
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

    final initCode = _getInitCode('createP256Account', [creation, salt.value]);
    final address =
        await _p256Accountfactory.getP256AccountAddress(salt.value, creation);
    return _createAccount(_chain, address, initCode);
  }

  SmartWallet _createAccount(
      Chain chain, EthereumAddress address, Uint8List initCalldata) {
    return SmartWallet(chain, address, initCalldata)
      ..addPlugin('signer', _signer)
      ..addPlugin('bundler', _bundler)
      ..addPlugin('jsonRpc', _jsonRpc)
      ..addPlugin('contract', _contract);
  }

  Uint8List _getInitCode(String functionName, List params) {
    final initCalldata =
        _simpleAccountfactory.self.function(functionName).encodeCall(params);
    List<int> extended = _chain.accountFactory!.addressBytes.toList();
    extended.addAll(initCalldata);
    return Uint8List.fromList(extended);
  }
}
