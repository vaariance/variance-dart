part of '../../variance.dart';

class PrivateKeySigner with SecureStorageMixin implements MultiSignerInterface {
  final Wallet _credential;

  @override
  String dummySignature =
      "0xfffffffffffffffffffffffffffffff0000000000000000000000000000000007aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1c";

  /// Creates a PrivateKeySigner instance using the provided EthPrivateKey.
  ///
  /// Parameters:
  /// - [privateKey]: The EthPrivateKey used to create the PrivateKeySigner.
  /// - [password]: The password for encrypting the private key.
  /// - [random]: The Random instance for generating random values.
  /// - [scryptN]: Scrypt parameter N (CPU/memory cost) for key derivation. Defaults to 8192.
  /// - [p]: Scrypt parameter p (parallelization factor) for key derivation. Defaults to 1.
  ///
  /// Example:
  /// ```dart
  /// final ethPrivateKey = EthPrivateKey.fromHex('your_private_key_hex');
  /// final password = 'your_password';
  /// final random = Random.secure();
  /// final privateKeySigner = PrivateKeySigner.create(ethPrivateKey, password, random);
  /// ```
  PrivateKeySigner.create(
      EthPrivateKey privateKey, String password, Random random,
      {int scryptN = 8192, int p = 1})
      : _credential = Wallet.createNew(privateKey, password, random,
            scryptN: scryptN, p: p);

  /// Creates a PrivateKeySigner instance with a randomly generated EthPrivateKey.
  ///
  /// Parameters:
  /// - [password]: The password for encrypting the private key.
  ///
  /// Example:
  /// ```dart
  /// final password = 'your_password';
  /// final privateKeySigner = PrivateKeySigner.createRandom(password);
  /// ```
  factory PrivateKeySigner.createRandom(String password) {
    final random = Random.secure();
    final privateKey = EthPrivateKey.createRandom(random);
    final credential = Wallet.createNew(privateKey, password, random);
    return PrivateKeySigner._internal(credential);
  }

  /// Creates a PrivateKeySigner instance from JSON representation.
  ///
  /// Parameters:
  /// - [source]: The JSON representation of the wallet.
  /// - [password]: The password for decrypting the private key.
  ///
  /// Example:
  /// ```dart
  /// final sourceJson = '{"privateKey": "your_private_key_encrypted", ...}';
  /// final password = 'your_password';
  /// final privateKeySigner = PrivateKeySigner.fromJson(sourceJson, password);
  /// ```
  factory PrivateKeySigner.fromJson(String source, String password) =>
      PrivateKeySigner._internal(
        Wallet.fromJson(source, password),
      );

  PrivateKeySigner._internal(this._credential);

  /// Returns the Ethereum address associated with the PrivateKeySigner.
  EthereumAddress get address => _credential.privateKey.address;

  /// Returns the public key associated with the PrivateKeySigner.
  Uint8List get publicKey => _credential.privateKey.encodedPublicKey;

  @override
  String getAddress({int index = 0, bytes}) {
    return address.hex;
  }

  @override
  Future<Uint8List> personalSign(Uint8List hash,
      {int? index, String? id}) async {
    return _credential.privateKey.signPersonalMessageToUint8List(hash);
  }

  @override
  Future<MsgSignature> signToEc(Uint8List hash,
      {int? index, String? id}) async {
    return _credential.privateKey.signToEcSignature(hash);
  }

  String toJson() => _credential.toJson();

  @override
  SecureStorageMiddleware withSecureStorage(FlutterSecureStorage secureStorage,
      {Authentication? authMiddleware}) {
    return SecureStorageMiddleware(
        secureStorage: secureStorage,
        authMiddleware: authMiddleware,
        credential: toJson());
  }

  /// Loads a PrivateKeySigner encrypted credentialJson from secure storage.
  ///
  /// Parameters:
  /// - [storageMiddleware]: The repository for secure storage.
  /// - [password]: The password for decrypting the private key.
  /// - [options]: Additional options for the authentication operation.
  ///
  /// Example:
  /// ```dart
  /// final storageMiddleware = SecureStorageRepository(); // Initialize your storage middleware
  /// final password = 'your_password';
  /// final privateKeySigner = await PrivateKeySigner.loadFromSecureStorage(
  ///   storageMiddleware: storageMiddleware,
  ///   password: password,
  ///   options: yourSSAuthOperationOptions,
  /// );
  /// ```
  static Future<PrivateKeySigner?> loadFromSecureStorage(
      {required SecureStorageRepository storageMiddleware,
      required String password,
      SSAuthOperationOptions? options}) {
    return storageMiddleware
        .readCredential(CredentialType.hdwallet, options: options)
        .then((value) =>
            value != null ? PrivateKeySigner.fromJson(value, password) : null);
  }
}
