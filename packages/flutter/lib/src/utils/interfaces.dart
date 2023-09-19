import 'dart:typed_data';

import 'package:passkeysafe/src/utils/passkeys.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

abstract class AccountFactoryInterface {
  Future<String> createAccount(
    EthereumAddress owner,
    BigInt salt, {
    required Credentials credentials,
    Transaction? transaction,
  });
  Future<EthereumAddress> getAddress(
    EthereumAddress owner,
    BigInt salt, {
    BlockNum? atBlock,
  });
  Future<String> createP256Account(
    String credentialId,
    BigInt pubKeyX,
    BigInt pubKeyY,
    BigInt salt, {
    required Credentials credentials,
    Transaction? transaction,
  });
  Future<EthereumAddress> getCredential(
    String credentialId,
    BigInt pubKeyX,
    BigInt pubKeyY,
    BigInt salt, {
    BlockNum? atBlock,
  });
}

abstract class HDkeysInterface {
  Future<String> getAddress(int index, {String? id});
  Future<MsgSignature> sign(Uint8List hash, {int? index, String? id});
}

abstract class PasskeysInterface {
  Future<PassKeySignature> sign(String hash, String credentialId);
}

// typedef StringToString = String Function(String);
// String applyToStringFunction(StringToString func, String input) {
//   return func(input);
// }

// typedef ToHex = String Function(String hexStr);

// ToHex CreateToHex() {
//   String toHex(int number) {
//     final hex = number.toRadixString(number);
//     return hex;
//   }

//   return toHex;
// }
