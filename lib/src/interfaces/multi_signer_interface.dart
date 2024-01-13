part of 'interfaces.dart';

/// An interface for a multi-signer, allowing signing of data and returning the result.
///
/// the multi-signer interface provides a uniform interface for accessing signer address and signing
/// messages in the Ethereum context. This allows for flexibility in creating different implementations
/// of multi-signers while adhering to a common interface.
/// interfaces include: [PrivateKeySigner], [PassKeySigner] and [HDWalletSigner]
abstract class MultiSignerInterface {
  /// The dummy signature is a valid signature that can be used for testing purposes.
  /// specifically, this will be used to simulate user operation on the entrypoint.
  /// You must specify a dummy signature that matches your transaction signature standard.
  String dummySignature = "0x";

  /// Generates an Ethereum address from the key at the specified [index].
  ///
  /// Parameters:
  /// - [index]: The index to determine which key to use for address generation. Defaults to 0.
  /// - [bytes]: Optional bytes for key generation. If not provided, it defaults to `null`.
  ///
  /// Example:
  /// ```dart
  /// final address = getAddress();
  /// ```
  String getAddress({int index = 0, bytes});

  /// Signs the provided [hash] using the personal sign method.
  ///
  /// Parameters:
  /// - [hash]: The hash to be signed.
  /// - [index]: The optional index to specify which privatekey to use for signing (required for HD wallets). If not provided, it defaults to `null`.
  /// - [id]: The optional identifier for the signing key. If not provided, it defaults to `null`. Required for passkey signers.
  ///
  /// Example:
  /// ```dart
  /// final hashToSign = Uint8List.fromList([0x01, 0x02, 0x03, 0x04]);
  /// final signature = await personalSign(hashToSign, index: 0, id: 'credentialId'); // credentialId is only required for passkey signers
  /// ```

  Future<Uint8List> personalSign(Uint8List hash, {int? index, String? id});

  /// Signs the provided [hash] using elliptic curve (EC) signatures and returns the r and s values.
  ///
  /// Parameters:
  /// - [hash]: The hash to be signed.
  /// - [index]: The optional index to specify which key to use for signing. If not provided, it defaults to `null`.
  /// - [id]: The optional identifier for the signing key. If not provided, it defaults to `null`. Required for passkey signers.
  ///
  /// Example:
  /// ```dart
  /// final hashToSign = Uint8List.fromList([0x01, 0x02, 0x03, 0x04]);
  /// final signature = await signToEc(hashToSign, index: 0, id: 'credentialId');
  /// ```
  Future<MsgSignature> signToEc(Uint8List hash, {int? index, String? id});
}

mixin SecureStorageMixin {
  /// Creates a `SecureStorageMiddleware` instance with the provided [FlutterSecureStorage].
  ///
  /// Parameters:
  /// - [secureStorage]: The FlutterSecureStorage instance to be used for secure storage.
  /// - [authMiddleware]: Optional authentication middleware. Defaults to `null`.
  ///
  /// Example:
  /// ```dart
  /// final flutterSecureStorage = FlutterSecureStorage();
  /// final secureStorageMiddleware = this.withSecureStorage(
  ///   flutterSecureStorage,
  ///   authMiddleware: myAuthMiddleware,
  /// );
  /// ```
  SecureStorageMiddleware withSecureStorage(FlutterSecureStorage secureStorage,
      {Authentication? authMiddleware});
}
