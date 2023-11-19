part of 'package:variance_dart/variance.dart';

class HDWalletSigner implements HDInterface {
  String? _mnemonic;
  final String _seed;

  late final EthereumAddress zerothAddress;

  HDWalletSigner({required String seed}) : _seed = seed {
    assert(seed.isNotEmpty, "seed cannot be empty");
  }

  /// Generates a new account in the HD wallet and stores it as zeroth.
  ///
  /// Returns the HD signer instance.
  factory HDWalletSigner.createWallet() {
    final mnemonic = bip39.generateMnemonic();
    return HDWalletSigner.recoverAccount(mnemonic);
  }

  /// Recovers an account from a mnemonic phrase and stores it in the HD wallet as zeroth.
  ///
  /// - [mnemonic]: The mnemonic phrase.
  ///
  /// Returns the HD signer instance.
  factory HDWalletSigner.recoverAccount(String mnemonic) {
    final seed = bip39.mnemonicToSeedHex(mnemonic);
    final signer = HDWalletSigner(seed: seed);
    signer.zerothAddress = signer._add(seed, 0);
    return signer;
  }

  @override
  EthereumAddress addAccount(int index) {
    return _add(_seed, index);
  }

  @override
  String? exportMnemonic() {
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
    return getEthereumAddress(index: index).hex;
  }

  @override
  EthereumAddress getEthereumAddress({int index = 0}) {
    bip44.ExtendedPrivateKey hdKey = _getHdKey(index);
    final privKey = _deriveEthPrivKey(hdKey.privateKeyHex());
    return privKey.address;
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

  bip44.ExtendedPrivateKey _getHdKey(int index) {
    return _deriveHdKey(_seed, index);
  }

  String? _getMnemonic() {
    if (_mnemonic != null) throw "exportMnemonic: Not a Valid Wallet";
    return _mnemonic;
  }

  EthPrivateKey _getPrivateKey(int index) {
    final hdKey = _getHdKey(index);
    final privateKey = _deriveEthPrivKey(hdKey.privateKeyHex());
    return privateKey;
  }
}
