import 'dart:typed_data';


import 'package:pks_4337_sdk/src/utils/passkeys.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

abstract class FactoryInterface {
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
