import 'dart:typed_data';

import 'package:pks_4337_sdk/src/signer/passkey_types.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

abstract class CredentialKeyInterface {
  EthereumAddress get address;
  Future<Uint8List> sign(Uint8List hash);
  Future<MsgSignature> signToEc(Uint8List hash);
}

abstract class HDkeyInterface {
  Future<EthereumAddress> getAddress(int index, {String? id});
  Future<Uint8List> sign(Uint8List hash, {int? index, String? id});
  Future<MsgSignature> signToEc(Uint8List hash, {int? index, String? id});
}

abstract class PasskeyInterface {
  Future<PassKeySignature> sign(String hash, String credentialId);
}
