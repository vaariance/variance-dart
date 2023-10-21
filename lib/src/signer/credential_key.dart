import 'dart:math';
import 'dart:typed_data';

import 'package:pks_4337_sdk/src/interfaces.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

/// Simple [Credential]
class CredentialKey implements CredentialKeyInterface {
  final Wallet _credential;

  CredentialKey.create(EthPrivateKey privateKey, String password, Random random,
      {int scryptN = 8192, int p = 1})
      : _credential = Wallet.createNew(privateKey, password, random,
            scryptN: scryptN, p: p);

  factory CredentialKey.createRandom(String password) {
    final random = Random.secure();
    final privateKey = EthPrivateKey.createRandom(random);
    final credential = Wallet.createNew(privateKey, password, random);
    return CredentialKey._internal(credential);
  }

  factory CredentialKey.fromJson(String source, String password) =>
      CredentialKey._internal(Wallet.fromJson(source, password));

  const CredentialKey._internal(
    this._credential,
  );

  @override
  EthereumAddress get address => _credential.privateKey.address;

  Uint8List get publicKey => _credential.privateKey.encodedPublicKey;

  @override
  Future<Uint8List> sign(Uint8List hash) async {
    return _credential.privateKey.signPersonalMessageToUint8List(hash);
  }

  @override
  Future<MsgSignature> signToEc(Uint8List hash) async {
    return _credential.privateKey.signToEcSignature(hash);
  }

  String toJson() => _credential.toJson();
}
