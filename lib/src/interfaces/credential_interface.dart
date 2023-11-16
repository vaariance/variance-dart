part of 'package:variance_dart/interfaces.dart';

/// An interface for basic credentials that can sign messages.
///
/// This interface defines the basic interface for wallet credential type that can
/// be used to sign messages in the Ethereum context.
abstract class CredentialInterface extends MultiSignerInterface {
  /// The Ethereum address associated with this credential.
  EthereumAddress get address;

  /// The public key associated with this credential.
  Uint8List get publicKey;

  /// Signs a message hash using the credential.
  ///
  /// The [index] and [id] parameters are ignored in this implementation.
  ///
  /// Returns a [Uint8List] representing the signature of the provided [hash].
  @override
  Future<Uint8List> personalSign(Uint8List hash, {int? index, String? id});

  /// Signs a message hash and returns the ECDSA signature.
  ///
  /// The [index] and [id] parameters are ignored in this implementation.
  ///
  /// Returns a [MsgSignature] representing the ECDSA signature of the provided [hash].
  @override
  Future<MsgSignature> signToEc(Uint8List hash, {int? index, String? id});

  /// Converts the credential to a JSON representation.
  ///
  /// Returns a JSON-encoded string representing the credential.
  String toJson();
}
