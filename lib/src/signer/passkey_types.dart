// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:typed_data';

import 'package:vaariance_dart/vaariance.dart';




class AuthData {
  final String credentialHex; // 32 bytes hex
  final String credentialId; // base64Url
  final List<String> publicKey;
  final String aaGUID;
  AuthData(this.credentialHex, this.credentialId, this.publicKey, this.aaGUID);
}

class PassKeyPair {
  final Uint8List credentialHexBytes;
  final String credentialId;
  final List<Uint256> publicKey;
  final String name;
  final String aaGUID;
  final DateTime registrationTime;
  PassKeyPair(this.credentialHexBytes, this.credentialId, this.publicKey,
      this.name, this.aaGUID, this.registrationTime);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'credentialHexBytes': credentialHexBytes.toList(),
      'credentialId': credentialId,
      'publicKey': publicKey.map((x) => x.toHex()).toList(),
      'name': name,
      'aaGUID': aaGUID,
      'registrationTime': registrationTime.millisecondsSinceEpoch,
    };
  }

  factory PassKeyPair.fromMap(Map<String, dynamic> map) {
    return PassKeyPair(
      Uint8List.fromList(map['credentialHexBytes']),
      map['credentialId'],
      List<Uint256>.from(
        (map['publicKey'] as List<String>).map<Uint256>(
          (x) => Uint256.fromHex(x),
        ),
      ),
      map['name'],
      map['aaGUID'],
      DateTime.fromMillisecondsSinceEpoch(map['registrationTime']),
    );
  }

  String toJson() => json.encode(toMap());

  factory PassKeyPair.fromJson(String source) =>
      PassKeyPair.fromMap(json.decode(source) as Map<String, dynamic>);
}

class PassKeySignature {
  final String credentialId;
  final List<Uint256> rs;
  final Uint8List authData;
  final String clientDataPrefix;
  final String clientDataSuffix;
  PassKeySignature(this.credentialId, this.rs, this.authData,
      this.clientDataPrefix, this.clientDataSuffix);

  Uint8List toHex() {
    return abi.encode([
      'uint256',
      'uint256',
      'bytes',
      'string',
      'string'
    ], [
      rs[0].value,
      rs[1].value,
      authData,
      clientDataPrefix,
      clientDataSuffix
    ]);
  }
}

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
