part of 'package:variance_dart/interfaces.dart';

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

  /// Returns the Hex address associated with the signer.
  ///
  /// Optional parameters:
  /// - [index]: The index or position of the signer. Used for multi-signature scenarios.
  /// - [id]: An optional identifier associated with the signing process.
  ///
  /// hex string length is 40+2 for Ethereum addresses and 64+2 Passkey compliant addresses
  ///
  /// Returns a [String] representing a valid hex string.
  String getAddress({int index = 0, bytes});

  /// Signs the provided [hash] using a multi-signature process.
  ///
  /// - [Uint8List]: The data type of signature expected.
  ///
  /// Optional parameters:
  /// - [index]: The index or position of the signer. Used for multi-signature scenarios.
  /// - [id]: An optional identifier associated with the signing process.
  ///
  /// Returns a Future<T> representing the signed data.
  Future<Uint8List> personalSign(Uint8List hash, {int? index, String? id});

  /// Signs the provided [hash] and returns the result as a [MsgSignature].
  ///
  /// Optional parameters:
  /// - [index]: The index or position of the signer. Used for multi-signature scenarios.
  /// - [id]: An optional identifier associated with the signing process.
  ///
  /// Returns a `Future<MsgSignature>` representing the r and s values.
  Future<MsgSignature> signToEc(Uint8List hash, {int? index, String? id});
}

mixin SecureStorageMixin {
  /// Wraps a [SecureStorage] instance with additional middleware.
  ///
  /// The [secureStorage] parameter represents the underlying secure storage
  /// implementation to be enhanced. The [authMiddleware] parameter, when provided,
  /// allows incorporating authentication features into secure storage operations.
  ///
  /// Returns a new instance of [SecureStorage] with the specified middleware.
  SecureStorageMiddleware withSecureStorage(SecureStorage secureStorage,
      {Authentication? authMiddleware});
}
