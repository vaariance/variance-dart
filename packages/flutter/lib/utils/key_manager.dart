import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import './common.dart';
import "package:bip39/bip39.dart" as bip39;
import 'package:bip32_bip44/dart_bip32_bip44.dart';

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

  Future _addSecret(String seed, {String? alias}) async {
    if (alias != null) {
      alias = alias + ksNamespace;
    }
    final key = _sha256(alias ?? ksNamespace);
    await _keyStore.write(key: key, value: seed);
  }

  Future<String?> _getSecret({String? alias}) async {
    final value = await _keyStore.read(key: alias ?? ksNamespace);
    return value;
  }

  // ignore: unused_element
  Future<void> _deleteSecret({String? alias}) async {
    await _keyStore.delete(key: alias ?? ksNamespace);
  }

  ExtendedPrivateKey _deriveHdKey(String seed, int idx) {
    final path = "m/44'/60'/0'/0/$idx";
    final chain = Chain.seed(seed);
    final hdKey = chain.forPath(path) as ExtendedPrivateKey;
    return hdKey;
  }

  EthPrivateKey _deriveEthPrivKey(String key) {
    final ethPrivateKey = EthPrivateKey.fromHex(key);
    return ethPrivateKey;
  }

  // _generate
  // internal function that calls the mnemonic.generate
  // returns a seed rather
  String _generate() {
    final mnemonic = bip39.generateMnemonic();
    _addSecret(mnemonic, alias: ksNamespace);
    return mnemonic;
  }

  // _recover
  // internal function that calls mnemonic.fromSeed
  Future<String> _recover(String mnemonic, {String? alias}) async {
    final seed = bip39.mnemonicToSeedHex(mnemonic);
    await _addSecret(seed, alias: alias);
    return seed;
  }

  String _add(String seed, int index, {String? alias}) {
    final hdKey = _deriveHdKey(seed, index);
    final privKey = _deriveEthPrivKey(hdKey.privateKeyHex());
    return privKey.address.hexEip55;
  }

  // getPubKey
  // returns the public key of the account by alias
  Future<ExtendedPrivateKey> _getHdKey(int index, {String? alias}) async {
    String? seed = await _getSecret(alias: alias);
    if (seed == null) throw Exception("getHdKey: Not a Valid Wallet");
    final hd = _deriveHdKey(seed, index);
    return hd;
  }

  Future _authWrapper() async {
    final didAuth = await _auth.authenticate(
      localizedReason: 'Please authenticate to access keystore',
    );
    if (!didAuth) throw Exception("Authentication failed");
  }

  // _sign
  // requires verification
  // uses the hd wallet in the keystore to sign the message
  Future<EthPrivateKey> _getPrivateKey(int index, {String? alias}) async {
    await _authWrapper();
    final hdKey = await _getHdKey(index, alias: alias);
    final privateKey = _deriveEthPrivKey(hdKey.privateKeyHex());
    return privateKey;
  }

  Future<String> _getMnemonic() async {
    await _authWrapper();
    final mnemonic = await _getSecret(alias: ksNamespace);
    if (mnemonic == null) throw "exportMnemonic: Not a Valid Wallet";
    return mnemonic;
  }

  // generate account
  // generates a new account based on hd
  // stores the hdWallet on keystore
  // returns an address
  Future<String> generateAccount({String? alias}) async {
    final mnemonic = _generate();
    final seed = await _recover(mnemonic, alias: alias);
    return _add(seed, 0, alias: alias);
  }

  // recover account
  // creates a hd wallet based on the provided seed phrase
  // stores it on keystore
  // returns the address
  Future<String> recoverAccount(String mnemonic, {String? alias}) async {
    final seed = await _recover(mnemonic, alias: alias);
    return _add(seed, 0, alias: alias);
  }

  Future<String> addAccount(int index, {String? alias}) async {
    await _authWrapper();
    final seed = await _getSecret(alias: alias);
    if (seed == null) throw Exception("addAccount: Not a Valid Wallet");
    return _add(seed, index, alias: alias);
  }

  /// sets a new alias for the hdKey.
  /// Alias must be one for each hd wallet
  /// the alias itself is the sha256 hash of the alias + ksNamespace;
  Future setAlias(String alias) async {
    final mnemonic = await _getMnemonic();
    await _recover(mnemonic, alias: alias);
  }

  // getPubKey
  // returns the public key of the account by alias
  Future<String> getAddress(int index, {String? alias}) async {
    ExtendedPrivateKey hdKey = await _getHdKey(index, alias: alias);
    final privKey = _deriveEthPrivKey(hdKey.privateKeyHex());
    return privKey.address.hexEip55;
  }

  // export mnemonic
  // retrieves the mnemonic
  // returns it.
  Future<String> exportMnemonic(String alias) async {
    final mnemonic = await _getMnemonic();
    return mnemonic;
  }

  // export private key
  Future<String> exportPrivateKey(int index, {String? alias}) async {
    final ethPrivateKey = await _getPrivateKey(index, alias: alias);
    Uint8List privKey = ethPrivateKey.privateKey;
    bool rlz = shouldRemoveLeadingZero(privKey);
    if (rlz) {
      privKey = privKey.sublist(1);
    }
    return hexlify(privKey);
  }

  /// utility hash function to generate hash to be signed as string
  String getMessageHashStr(String str) {
    final hash = keccakUtf8(str);
    return hexlify(hash);
  }

  /// signMessage
  /// external function that does the actual signing
  Future<MsgSignature> signMessage(Uint8List message,
      {int? index, String? alias}) async {
    final privKey = await _getPrivateKey(index ?? 0, alias: alias);
    final signature = privKey.signToEcSignature(message);
    return signature;
  }
}
