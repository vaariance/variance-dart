library pks_4337_sdk;

import 'dart:convert';
import 'dart:typed_data';

import 'package:bip32_bip44/dart_bip32_bip44.dart';
import "package:bip39/bip39.dart" as bip39;
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );

class HDKey implements HDkeysInterface {
  String ksNamespace;
  final FlutterSecureStorage _keyStore;
  final LocalAuthentication _auth = LocalAuthentication();
  HDKey({required this.ksNamespace})
      : _keyStore = FlutterSecureStorage(aOptions: _getAndroidOptions());

  ///[addAccount]
  ///
  ///Accepts an index, gets seed from keystore and returns a new account
  Future<String> addAccount(int index, {String? id}) async {
    await _authWrapper();
    final seed = await _getSecret(id: id);
    if (seed == null) throw Exception("addAccount: Not a Valid Wallet");
    return _add(seed, index, id: id);
  }

  /// [exportMnemonic]
  // retrieves the mnemonic
  // returns it.
  Future<String> exportMnemonic(String id) async {
    final mnemonic = await _getMnemonic();
    return mnemonic;
  }

  /// [exportPrivateKey]
  /// returns the private key
  Future<String> exportPrivateKey(int index, {String? id}) async {
    final ethPrivateKey = await _getPrivateKey(index, id: id);
    Uint8List privKey = ethPrivateKey.privateKey;
    bool rlz = shouldRemoveLeadingZero(privKey);
    if (rlz) {
      privKey = privKey.sublist(1);
    }
    return hexlify(privKey);
  }

  /// [generateAccount]
  ///generates a new account based on hd,
  /// stores the hdWallet on keystore,
  ///  and returns an address
  Future<String> generateAccount({String? id}) async {
    final mnemonic = _generate();
    final seed = await _recover(mnemonic, id: id);
    return _add(seed, 0, id: id);
  }

  // getPubKey
  // returns the public key of the account by id
  @override
  Future<String> getAddress(int index, {String? id}) async {
    ExtendedPrivateKey hdKey = await _getHdKey(index, id: id);
    final privKey = _deriveEthPrivKey(hdKey.privateKeyHex());
    return privKey.address.hexEip55;
  }

  /// [signMessage]
  /// External function that does the actual signing
  Future<Uint8List> personalSign(Uint8List message,
      {int? index, String? id}) async {
    final privKey = await _getPrivateKey(index ?? 0, id: id);
    return privKey.signPersonalMessageToUint8List(message);
  }

  /// [recoverAccount]
  /// Creates a hd wallet based on the provided seed phrase,
  /// stores it on keystore,
  // and returns the address
  Future<String> recoverAccount(String mnemonic, {String? id}) async {
    final seed = await _recover(mnemonic, id: id);
    return _add(seed, 0, id: id);
  }

  /// sets a new id for the hdKey.
  /// Id must be one for each hd wallet
  /// the id itself is the sha256 hash of the id + ksNamespace;
  Future setId(String id) async {
    final mnemonic = await _getMnemonic();
    await _recover(mnemonic, id: id);
  }

  @override
  Future<Uint8List> sign(Uint8List hash, {int? index, String? id}) async {
    final privKey = await _getPrivateKey(index ?? 0, id: id);
    return privKey.signPersonalMessageToUint8List(hash);
  }

  @override
  Future<MsgSignature> signToEc(Uint8List hash,
      {int? index, String? id}) async {
    final privKey = await _getPrivateKey(index ?? 0, id: id);
    return privKey.signToEcSignature(hash);
  }

  ///[_add]
  ///
  ///An internal function to add new wallet account using saved seed and index
  String _add(String seed, int index, {String? id}) {
    final hdKey = _deriveHdKey(seed, index);
    final privKey = _deriveEthPrivKey(hdKey.privateKeyHex());
    return privKey.address.hexEip55;
  }

  ///[_addSecret]
  ///
  ///Adds a seed to the client keystore using [flutter_secure_storage]
  Future _addSecret(String seed, {String? id}) async {
    if (id != null) {
      id = id + ksNamespace;
    }
    final key = _sha256(id ?? ksNamespace);
    await _keyStore.write(key: key, value: seed);
  }

  ///Internal that request authentication before accessing keystore
  Future _authWrapper() async {
    final didAuth = await _auth.authenticate(
      localizedReason: 'Please authenticate to access keystore',
    );
    if (!didAuth) throw Exception("Authentication failed");
  }

  ///Delete existing seed by id
  Future<void> _deleteSecret({String? id}) async {
    await _keyStore.delete(key: id ?? ksNamespace);
  }

  ///[_deriveEthPrivKey]
  ///
  ///Derives an eth private key from the hd key
  EthPrivateKey _deriveEthPrivKey(String key) {
    final ethPrivateKey = EthPrivateKey.fromHex(key);
    return ethPrivateKey;
  }

  ///[_deriveHdKey]
  ///
  ///Derives a hd wallet from the seed and index
  ExtendedPrivateKey _deriveHdKey(String seed, int idx) {
    ///Ethereum derivation path
    final path = "m/44'/60'/0'/0/$idx";
    final chain = Chain.seed(seed);
    final hdKey = chain.forPath(path) as ExtendedPrivateKey;
    return hdKey;
  }

  ///[_generate]
  /// internal function that generates a bip39 mnemonic
  ///
  /// and saves the mnemonic to client keystore
  String _generate() {
    final mnemonic = bip39.generateMnemonic();
    _addSecret(mnemonic, id: ksNamespace);
    return mnemonic;
  }

  ///[_getHdKey]
  ///
  // Internal function to get an hd key based on bip39 from an index and an optional id
  Future<ExtendedPrivateKey> _getHdKey(int index, {String? id}) async {
    String? seed = await _getSecret(id: id);
    if (seed == null) throw Exception("getHdKey: Not a Valid Wallet");
    final hd = _deriveHdKey(seed, index);
    return hd;
  }

  ///[_getMnemonic]
  ///
  ///Internal function to get mnemonic from seed
  Future<String> _getMnemonic() async {
    await _authWrapper();
    final mnemonic = await _getSecret(id: ksNamespace);
    if (mnemonic == null) throw "exportMnemonic: Not a Valid Wallet";
    return mnemonic;
  }

  /// [_getPrivateKey]
  ///
  ///
  Future<EthPrivateKey> _getPrivateKey(int index, {String? id}) async {
    await _authWrapper();
    final hdKey = await _getHdKey(index, id: id);
    final privateKey = _deriveEthPrivKey(hdKey.privateKeyHex());
    return privateKey;
  }

  ///[_getSecret]
  ///
  ///Fetches and returns the seed from client keystore using an id
  Future<String?> _getSecret({String? id}) async {
    final value = await _keyStore.read(key: id ?? ksNamespace);
    return value;
  }

  /// [_recover]
  ///
  /// Internal function that recovers the seed from the provided mnemonic and saves it to client keystore
  Future<String> _recover(String mnemonic, {String? id}) async {
    final seed = bip39.mnemonicToSeedHex(mnemonic);
    await _addSecret(seed, id: id);
    return seed;
  }

  ///Hashing util
  String _sha256(String id) {
    final bytes = utf8.encode(id);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
