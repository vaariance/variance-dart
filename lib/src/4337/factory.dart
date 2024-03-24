part of '../../variance.dart';

class SmartWalletFactory implements SmartWalletFactoryBase {
  final Chain _chain;
  final MSI _signer;

  late final JsonRPCProvider _jsonRpc;
  late final BundlerProvider _bundler;
  late final Contract _contract;

  SmartWalletFactory(this._chain, this._signer)
      : assert(_chain.accountFactory != null, "account factory not set"),
        _jsonRpc = JsonRPCProvider(_chain),
        _bundler = BundlerProvider(_chain) {
    _contract = Contract(_jsonRpc.rpc);
  }

  _SimpleAccountFactory get _simpleAccountfactory => _SimpleAccountFactory(
      address: _chain.accountFactory!,
      chainId: _chain.chainId,
      rpc: _jsonRpc.rpc);

  Future<SmartWallet> createSimpleAccount(Uint256 salt, {int? index}) async {
    final signer = _signer.getAddress(index: index ?? 0);
    final address = await _simpleAccountfactory.getAddress(
        EthereumAddress.fromHex(signer), salt.value);
    final initCode = _getInitCode('createAccount', [signer, salt.value]);
    return _createAccount(_chain, address, initCode);
  }

  Future<SmartWallet> createP256Account<T>(T keyPair, Uint256 salt) {
    switch (keyPair.runtimeType) {
      case PassKeyPair _:
        return _createPasskeyAccount(keyPair as PassKeyPair, salt);
      case P256Credential _:
        return _createSecureEnclaveAccount(keyPair as P256Credential, salt);
      default:
        throw ArgumentError("unsupported key pair type");
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

  Future<SmartWallet> _createPasskeyAccount(
      PassKeyPair pkp, Uint256 salt) async {
    final initCode = _getInitCode('createPasskeyAccount', [
      hexToBytes(pkp.credentialHex),
      pkp.publicKey.item1.value,
      pkp.publicKey.item2.value,
      salt.value
    ]);
    final address = await _simpleAccountfactory.getPasskeyAccountAddress(
        hexToBytes(pkp.credentialHex),
        pkp.publicKey.item1.value,
        pkp.publicKey.item2.value,
        salt.value);
    return _createAccount(_chain, address, initCode);
  }

  Future<SmartWallet> _createSecureEnclaveAccount(
      P256Credential p256, Uint256 salt) {
    // TODO: implement _createSimpleSecureEnclaveAccount
    throw UnimplementedError();
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
