part of '../../variance.dart';

class HDWalletSigner with SecureStorageMixin implements HDInterface {
  final String _mnemonic;

  final String _seed;

  late final EthereumAddress zerothAddress;

  @override
  String dummySignature =
      "0xfffffffffffffffffffffffffffffff0000000000000000000000000000000007aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1c";

  /// Creates a new HD wallet signer instance by generating a random mnemonic phrase.
  ///
  /// Example:
  /// ```dart
  /// final walletSigner = HDWalletSigner.createWallet();
  /// ```
  factory HDWalletSigner.createWallet() {
    return HDWalletSigner.recoverAccount(bip39.generateMnemonic());
  }

  /// Recovers an HD wallet signer instance from a given mnemonic phrase.
  ///
  /// Parameters:
  /// - [mnemonic]: The mnemonic phrase used for recovering the HD wallet signer.
  ///
  /// Example:
  /// ```dart
  /// final mnemonicPhrase = 'word1 word2 word3 ...'; // Replace with an actual mnemonic phrase
  /// final recoveredSigner = HDWalletSigner.recoverAccount(mnemonicPhrase);
  /// ```

  factory HDWalletSigner.recoverAccount(String mnemonic) {
    final seed = bip39.mnemonicToSeedHex(mnemonic);
    final signer = HDWalletSigner._internal(seed: seed, mnemonic: mnemonic);
    signer.zerothAddress = signer._add(seed, 0);
    return signer;
  }

  HDWalletSigner._internal({required String seed, required String mnemonic})
      : _seed = seed,
        _mnemonic = mnemonic {
    assert(seed.isNotEmpty, "seed cannot be empty");
  }

  @override
  EthereumAddress addAccount(int index) {
    return _add(_seed, index);
  }

  @override
  String exportMnemonic() {
    return _getMnemonic();
  }

  @override
  String exportPrivateKey(int index) {
    final ethPrivateKey = _getPrivateKey(index);
    Uint8List privKey = ethPrivateKey.privateKey;
    bool rlz = shouldRemoveLeadingZero(privKey);
    if (rlz) {
      privKey = privKey.sublist(1);
    }
    return hexlify(privKey);
  }

  @override
  String getAddress({int index = 0, bytes}) {
    return _getEthereumAddress(index: index).hex;
  }

  @override
  Future<Uint8List> personalSign(Uint8List hash,
      {int? index, String? id}) async {
    final privKey = _getPrivateKey(index ?? 0);
    return privKey.signPersonalMessageToUint8List(hash);
  }

  @override
  Future<MsgSignature> signToEc(Uint8List hash,
      {int? index, String? id}) async {
    final privKey = _getPrivateKey(index ?? 0);
    return privKey.signToEcSignature(hash);
  }

  @override
  SecureStorageMiddleware withSecureStorage(FlutterSecureStorage secureStorage,
      {Authentication? authMiddleware}) {
    return SecureStorageMiddleware(
        secureStorage: secureStorage,
        authMiddleware: authMiddleware,
        credential: _getMnemonic());
  }

  EthereumAddress _add(String seed, int index) {
    final hdKey = _deriveHdKey(seed, index);
    final privKey = _deriveEthPrivKey(hdKey.privateKeyHex());
    return privKey.address;
  }

  EthPrivateKey _deriveEthPrivKey(String key) {
    final ethPrivateKey = EthPrivateKey.fromHex(key);
    return ethPrivateKey;
  }

  bip44.ExtendedPrivateKey _deriveHdKey(String seed, int idx) {
    final path = "m/44'/60'/0'/0/$idx";
    final chain = bip44.Chain.seed(seed);
    final hdKey = chain.forPath(path) as bip44.ExtendedPrivateKey;
    return hdKey;
  }

  EthereumAddress _getEthereumAddress({int index = 0}) {
    bip44.ExtendedPrivateKey hdKey = _getHdKey(index);
    final privKey = _deriveEthPrivKey(hdKey.privateKeyHex());
    return privKey.address;
  }

  bip44.ExtendedPrivateKey _getHdKey(int index) {
    return _deriveHdKey(_seed, index);
  }

  String _getMnemonic() {
    return _mnemonic;
  }

  EthPrivateKey _getPrivateKey(int index) {
    final hdKey = _getHdKey(index);
    final privateKey = _deriveEthPrivKey(hdKey.privateKeyHex());
    return privateKey;
  }

  /// Loads an HD wallet signer instance from secure storage using the provided [SecureStorageRepository].
  ///
  /// Parameters:
  /// - [storageMiddleware]: The secure storage repository used to retrieve the HD wallet credentials.
  /// - [options]: Optional authentication operation options. Defaults to `null`.
  ///
  /// Returns a `Future` that resolves to a `HDWalletSigner` instance if successfully loaded, or `null` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final secureStorageRepo = SecureStorageRepository(); // Replace with an actual instance
  /// final loadedSigner = await HDWalletSigner.loadFromSecureStorage(
  ///   storageMiddleware: secureStorageRepo,
  /// );
  /// ```
  static Future<HDWalletSigner?> loadFromSecureStorage(
      {required SecureStorageRepository storageMiddleware,
      SSAuthOperationOptions? options}) {
    return storageMiddleware
        .readCredential(CredentialType.hdwallet, options: options)
        .then((value) =>
            value != null ? HDWalletSigner.recoverAccount(value) : null);
  }
}
