part of 'package:variance_dart/interfaces.dart';

abstract class PasskeyInterface extends MultiSignerInterface {
  /// Gets the PassKeysOptions used by the PasskeyInterface.
  PassKeysOptions get opts;

  /// Gets the default credential ID used by the Passkey.
  String? get defaultId;

  /// Creates a client data hash for PassKeys authentication.
  ///
  /// - [options]: The PassKeysOptions for the client data hash.
  /// - [challenge]: A random challenge for the client data hash.
  ///
  /// Returns a [Uint8List] representing the client data hash.
  Uint8List clientDataHash(PassKeysOptions options, {String? challenge});

  /// Creates a 32-byte client data hash for PassKeys authentication.
  ///
  /// - [options]: The PassKeysOptions for the client data hash.
  /// - [challenge]: A random challenge for the client data hash.
  ///
  /// Returns a [Uint8List] representing the 32-byte client data hash.
  Uint8List clientDataHash32(PassKeysOptions options, {String? challenge});

  /// Converts a credentialId to a 32-byte hex string.
  ///
  /// - [credentialId]: The credentialId to convert.
  ///
  /// Returns a 32-byte hex string.
  String credentialIdToBytes32Hex(List<int> credentialId);

  /// Gets the messaging signature from the PassKeys authentication response.
  ///
  /// - [signatureBytes]: The base64 encoded signature.
  ///
  /// Returns a [List] containing [String] values representing 'r' and 's'.
  Future<List<String>> getMessagingSignature(Uint8List signatureBytes);

  /// Registers a user and returns a PassKeyPair key pair.
  ///
  /// - [name]: The user name.
  /// - [requiresUserVerification]: True if user verification is required.
  ///
  /// Returns a [PassKeyPair].
  Future<PassKeyPair> register(String name, bool requiresUserVerification);

  /// Signs the intended request and returns the signedMessage.
  ///
  /// - [hash]: The hash of the intended request.
  /// - [credentialId]: The credential id.
  ///
  /// Returns a [PassKeySignature].
  Future<PassKeySignature> signToPasskeySignature(Uint8List hash, String credentialId);
}
