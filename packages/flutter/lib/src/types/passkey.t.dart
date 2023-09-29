
import 'dart:typed_data';

import 'package:pks_4337_sdk/pks_4337_sdk.dart';

class PassKeysOptions {
  final String namespace;
  final String name;
  final String origin;
  bool? crossOrigin;
  String? challenge;
  String? type;
  PassKeysOptions(
      {required this.namespace,
      required this.name,
      required this.origin,
      this.crossOrigin,
      this.challenge,
      this.type});
}

class AuthData {
  final String credentialHex; // 32 bytes hex
  final String credentialId; // base64Url
  final List<String> publicKey;
  final String aaGUID;
  AuthData(this.credentialHex, this.credentialId, this.publicKey, this.aaGUID);
}

class PassKeyPair {
  final String credentialHex;
  final String credentialId;
  final List<Uint256?> publicKey;
  final String name;
  final String aaGUID;
  final DateTime registrationTime;
  PassKeyPair(this.credentialHex, this.credentialId, this.publicKey, this.name,
      this.aaGUID, this.registrationTime);
}

class PassKeySignature {
  final String credentialId;
  final List<Uint256> rs;
  final Uint8List authData;
  final String clientDataPrefix;
  final String clientDataSuffix;
  PassKeySignature(this.credentialId, this.rs, this.authData,
      this.clientDataPrefix, this.clientDataSuffix);
}
