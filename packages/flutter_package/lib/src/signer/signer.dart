library pks_4337_sdk;

import 'dart:typed_data';

import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:web3dart/crypto.dart';

export 'hd_key.dart';
export 'passkey.dart';

/// [Signer] class for signing transactions with [PassKey] or [HDKey]
class Signer {
  final PasskeysInterface? passkey;
  final HDkeysInterface? hdkey;

  SignerType defaultSigner;

  Signer({this.passkey, this.hdkey, SignerType signer = SignerType.hdkey})
      : assert(passkey != null || hdkey != null),
        defaultSigner = signer;

  Future<T> sign<T>(Uint8List hash, {int? index, String? id}) async {
    switch (defaultSigner) {
      case SignerType.passkey:
        require(
            id != null && id.isNotEmpty, "Passkey Credential ID is required");
        return await passkey!.sign(bytesToHex(hash), id!) as T;
      default:
        return await hdkey!.sign(hash, index: index, id: id) as T;
    }
  }
}

enum SignerType { passkey, hdkey, credential }
