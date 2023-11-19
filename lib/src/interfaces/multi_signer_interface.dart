part of 'package:variance_dart/interfaces.dart';

/// An interface for a multi-signer, allowing signing of data and returning the result.
///
/// the multi-signer interface provides a uniform interface for accessing signer address and signing
/// messages in the Ethereum context. This allows for flexibility in creating different implementations
/// of multi-signers while adhering to a common interface.
/// interfaces include: [CredentialSigner], [PassKeySigner] and [HDWalletSigner]
abstract class MultiSignerInterface {
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
  /// Returns a Future<MsgSignature> representing the r and s values.
  Future<MsgSignature> signToEc(Uint8List hash, {int? index, String? id});
}
