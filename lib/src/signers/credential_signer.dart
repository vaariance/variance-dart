part of 'package:variance_dart/variance.dart';

class CredentialSigner implements CredentialInterface {
  final Wallet _credential;

  CredentialSigner.create(
      EthPrivateKey privateKey, String password, Random random,
      {int scryptN = 8192, int p = 1})
      : _credential = Wallet.createNew(privateKey, password, random,
            scryptN: scryptN, p: p);

  factory CredentialSigner.createRandom(String password) {
    final random = Random.secure();
    final privateKey = EthPrivateKey.createRandom(random);
    final credential = Wallet.createNew(privateKey, password, random);
    return CredentialSigner._internal(credential);
  }

  factory CredentialSigner.fromJson(String source, String password) =>
      CredentialSigner._internal(Wallet.fromJson(source, password));

  const CredentialSigner._internal(
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
}
