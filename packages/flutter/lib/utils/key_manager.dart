import 'dart:typed_data';
import 'package:hd_wallet_kit/hd_wallet_kit.dart';
import 'package:hd_wallet_kit/utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );

class KeyManager {
  String ksNamespace;
  final FlutterSecureStorage _keyStore;
  final LocalAuthentication _auth = LocalAuthentication();
  KeyManager({required this.ksNamespace})
      : _keyStore = FlutterSecureStorage(aOptions: _getAndroidOptions());

  String _sha256(String alias) {
    final bytes = utf8.encode(alias);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future _addSecret(Uint8List seed, {String? alias}) async {
    if (alias != null) {
      alias = alias + ksNamespace;
    }
    final key = _sha256(alias ?? ksNamespace);
    await _keyStore.write(key: key, value: uint8ListToHexString(seed));
  }

  Future<String?> _getSecret({String? alias}) async {
    final value = await _keyStore.read(key: alias ?? this.ksNamespace);
    return value;
  }

  Future<void> _deleteSecret({String? alias}) async {
    await _keyStore.delete(key: alias ?? this.ksNamespace);
  }

  HDKey deriveKey(HDWallet hd, int idx) {
    final bip44Key = hd.deriveKey(
        purpose: Purpose.BIP44,
        coinType: 60,
        account: 0,
        change: 0,
        index: idx);
    return bip44Key;
  }

  // _generate
  // internal function that calls the mnemonic.generate
  // returns a seed rather
  List<String> _generate() {
    final mnemonic = Mnemonic.generate();
    _addSecret(Uint8List.fromList(utf8.encode(mnemonic.join(":"))),
        alias: ksNamespace);
    return mnemonic;
  }

  // _recover
  // internal function that calls mnemonic.fromSeed
  Uint8List _recover(List<String> mnemonic, [String alias = ""]) {
    final seed = Mnemonic.toSeed(mnemonic, _sha256(alias));
    return seed;
  }

  Future<String> _add(Uint8List seed, int index, {String? alias}) async {
    final hd = HDWallet.fromSeed(seed: seed);
    await _addSecret(seed, alias: alias);
    final hdKey = deriveKey(hd, index);
    return hdKey.encodeAddress();
  }

  // generate account
  // generates a new account based on hd
  // stores the hdWallet on keystore
  // returns an address
  Future<String> generateAccount({String? alias}) async {
    final mnemonic = _generate();
    final seed = _recover(mnemonic, alias ?? "");
    return await _add(seed, 0, alias: alias);
  }

  // recover account
  // creates a hd wallet based on the provided seed phrase
  // stores it on keystore
  // returns the address
  Future<String> recoverAccount(List<String> mnemonic, {String? alias}) async {
    final seed = _recover(mnemonic, alias ?? "");
    return await _add(seed, 0, alias: alias);
  }

  // getPubKey
  // returns the public key of the account by alias
  Future<HDKey> _getHdKey(int index, {String? alias}) async {
    String? seed = await _getSecret(alias: alias);
    if (seed == null) throw Exception("getHdKey: Not a Valid Wallet");
    Uint8List decodedSeed = hexStringToUint8List(seed);
    final hd = HDWallet.fromSeed(seed: decodedSeed);
    return deriveKey(hd, index);
  }

  // getPubKey
  // returns the public key of the account by alias
  Future<String> getPubKey(int index, {String? alias}) async {
    HDKey hdKey = await _getHdKey(index, alias: alias);
    return hdKey.serializePublic(HDExtendedKeyVersion.xpub);
  }

  // getAddress
  // returns the address of the account by alias
  Future<String> getAddress(int index, {String? alias}) async {
    HDKey pubKey = await _getHdKey(index, alias: alias);
    return pubKey.encodeAddress();
  }

  Future<bool> _authWrapper() async {
    final didAuth = await _auth.authenticate(
      localizedReason: 'Please authenticate to access keystore',
    );
    return didAuth;
  }

  // _sign
  // requires verification
  // uses the hd wallet in the keystore to sign the message
  Future<BigInt> _getPrivateKey(int index, {String? alias}) async {
    final isAuthenticated = await _authWrapper();
    if (isAuthenticated) {
      final hdKey = await _getHdKey(index, alias: alias);
      final privateKey = hdKey.privKey;

      // Ensure the privateKey is not null.
      if (privateKey == null) {
        throw Exception("Private key not found");
      }

      return privateKey;
    } else {
      // Handle authentication failure here if needed.
      throw Exception("Authentication failed");
    }
  }

  // _getMnemonic
  // TODO:
  // wrap with  auth

  // signMessage
  // external function that does the actual signing
  Future<MsgSignature> signMessage(String message,
      {int? index, String? alias}) async {
    final privKey = await _getPrivateKey(index ?? 0, alias: alias);
    Credentials credentials = EthPrivateKey.fromInt(privKey);
    //hash the message
    final hashedMessage = _hashMessage(message);

    //sign the message
    final signedMessage = credentials.signToEcSignature(hashedMessage);
    return signedMessage;
  }

  ///Internal hash function that does the actual signing of the message
  int MULTIPLIER = 31;
  Uint8List _hashMessage(String str) {
    int h = 0;
    for (int i = 0; i < str.length; i++) {
      h = MULTIPLIER * h + str.codeUnitAt(i);
    }

    // Convert the hash value to a Uint8List
    final hashBytes = Uint8List(4);
    for (int i = 0; i < 4; i++) {
      hashBytes[i] = (h >> (i * 8)) & 0xFF;
    }

    return hashBytes;
  }

  Future<List<String>> _getMnemonic(String alias) async {
    final isAuthenticated = await _authWrapper();
    if (isAuthenticated) {
      final mnemonic = await _getSecret(alias: ksNamespace);
      if (mnemonic == null) throw "exportMnemonic: Not a Valid Wallet";
      List<String> decodedMnemonic =
          utf8.decode(hexStringToUint8List(mnemonic)).split(":");
      return decodedMnemonic;
    } else {
      throw Exception("Authentication failed");
    }
  }

  // export mnemonic
  // retrieves the mnemonic
  // returns it.
  Future<List<String>> exportMnemonic(String alias) async {
    final isAuthenticated = await _authWrapper();
    if (isAuthenticated) {
      final mnemonic = await _getMnemonic(alias);
      return mnemonic;
    } else {
      throw Exception("Authentication failed");
    }
  }

  // export private key
  Future<BigInt> exportPrivateKey(int index, {String? alias}) async {
    final isAuthenticated = await _authWrapper();
    if (isAuthenticated) {
      final privKey = await _getPrivateKey(index, alias: alias);
      return privKey;
    } else {
      throw Exception("Authentication failed");
    }
  }
}

// TODO:
// requiresAuth?: 


// TODO:
// addAccount


// basically returns an address for an account with the specified index
// addAccount(alias, index);
// use auth
// gets the mnemonic, the derives the account of specified index;s