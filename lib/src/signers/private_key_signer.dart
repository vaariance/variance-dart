part of 'package:variance_dart/variance.dart';

class PrivateKeySigner with SecureStorageMixin implements CredentialInterface {
  final Wallet _credential;

  PrivateKeySigner.create(
      EthPrivateKey privateKey, String password, Random random,
      {int scryptN = 8192, int p = 1})
      : _credential = Wallet.createNew(privateKey, password, random,
            scryptN: scryptN, p: p);

  factory PrivateKeySigner.createRandom(String password) {
    final random = Random.secure();
    final privateKey = EthPrivateKey.createRandom(random);
    final credential = Wallet.createNew(privateKey, password, random);
    return PrivateKeySigner._internal(credential);
  }

  factory PrivateKeySigner.fromJson(String source, String password) =>
      PrivateKeySigner._internal(Wallet.fromJson(source, password));

  static Future<PrivateKeySigner?> loadFromSecureStorage(
      {required SecureStorageRepository storageMiddleware,
      required String password,
      SSAuthOperationOptions? options}) {
    return storageMiddleware
        .readCredential(CredentialType.hdwallet, options: options)
        .then((value) =>
            value != null ? PrivateKeySigner.fromJson(value, password) : null);
  }

  const PrivateKeySigner._internal(
    this._credential,
  );

  @override
  EthereumAddress get address => _credential.privateKey.address;

  @override
  Uint8List get publicKey => _credential.privateKey.encodedPublicKey;

  @override
  String getAddress({int index = 0, bytes}) {
    return address.hex;
  }

  @override
  Future<Uint8List> personalSign(Uint8List hash,
      {int? index, String? id}) async {
    return _credential.privateKey.signPersonalMessageToUint8List(hash);
  }

  @override
  Future<MsgSignature> signToEc(Uint8List hash,
      {int? index, String? id}) async {
    return _credential.privateKey.signToEcSignature(hash);
  }

  @override
  String toJson() => _credential.toJson();

  @override
  SecureStorageMiddleware withSecureStorage(SecureStorage secureStorage,
      {Authentication? authMiddleware}) {
    return SecureStorageMiddleware(
        secureStorage: secureStorage,
        authMiddleware: authMiddleware,
        credential: toJson());
  }
}
