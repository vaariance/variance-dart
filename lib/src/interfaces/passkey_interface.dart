part of 'interfaces.dart';

abstract class PasskeyInterface extends MultiSignerInterface {
  /// Gets the PassKeysOptions used by the PasskeyInterface.
  PassKeysOptions get opts;

  /// Gets the default credential ID used by the Passkey.
  String? get defaultId;

  /// Generates the client data hash for the given [PassKeysOptions] and optional challenge.
  ///
  /// Parameters:
  /// - [options]: PassKeysOptions containing the authentication options.
  /// - [challenge]: Optional challenge value. Defaults to a randomly generated challenge if not provided.
  ///
  /// Returns the Uint8List representation of the client data hash.
  ///
  /// Example:
  /// ```dart
  /// final passKeysOptions = PassKeysOptions(type: 'webauthn', origin: 'https://example.com');
  /// final clientDataHash = clientDataHash(passKeysOptions);
  /// ```
  Uint8List clientDataHash(PassKeysOptions options, {String? challenge});

  /// Generates the 32-byte client data hash for the given [PassKeysOptions] and optional challenge.
  ///
  /// Parameters:
  /// - [options]: PassKeysOptions containing the authentication options.
  /// - [challenge]: Optional challenge value. Defaults to a randomly generated challenge if not provided.
  ///
  /// Returns the Uint8List representation of the 32-byte client data hash.
  ///
  /// Example:
  /// ```dart
  /// final passKeysOptions = PassKeysOptions(type: 'webauthn', origin: 'https://example.com');
  /// final clientDataHash32 = clientDataHash32(passKeysOptions);
  /// ```
  Uint8List clientDataHash32(PassKeysOptions options, {String? challenge});

  /// Converts a List<int> credentialId to a hex string representation with a length of 32 bytes.
  ///
  /// Parameters:
  /// - [credentialId]: List of integers representing the credentialId.
  ///
  /// Returns the hex string representation of the credentialId padded to 32 bytes.
  ///
  /// Example:
  /// ```dart
  /// final credentialId = [1, 2, 3];
  /// final hexString = credentialIdToBytes32Hex(credentialId);
  /// ```
  String credentialIdToBytes32Hex(List<int> credentialId);

  /// Parses ASN1-encoded signature bytes and returns a List of two hex strings representing the `r` and `s` values.
  ///
  /// Parameters:
  /// - [signatureBytes]: Uint8List containing the ASN1-encoded signature bytes.
  ///
  /// Returns a Future<List<String>> containing hex strings for `r` and `s` values.
  ///
  /// Example:
  /// ```dart
  /// final signatureBytes = Uint8List.fromList([48, 68, 2, 32, ...]);
  /// final signatureHexValues = await getMessagingSignature(signatureBytes);
  /// ```
  Future<List<String>> getMessagingSignature(Uint8List signatureBytes);

  /// Registers a new PassKeyPair.
  ///
  /// Parameters:
  /// - [name]: The name associated with the PassKeyPair.
  /// - [requiresUserVerification]: A boolean indicating whether user verification is required.
  ///
  /// Returns a Future<PassKeyPair> representing the registered PassKeyPair.
  ///
  /// Example:
  /// ```dart
  /// final pkps = PassKeySigner("example", "example.com", "https://example.com");
  /// final passKeyPair = await pkps.register('geffy', true);
  /// ```
  Future<PassKeyPair> register(String name, bool requiresUserVerification);

  /// Signs a hash using the PassKeyPair associated with the given credentialId.
  ///
  /// Parameters:
  /// - [hash]: The hash to be signed.
  /// - [credentialId]: The credentialId associated with the PassKeyPair.
  ///
  /// Returns a Future<PassKeySignature> representing the PassKeySignature of the signed hash.
  ///
  /// Example:
  /// ```dart
  /// final hash = Uint8List.fromList([/* your hash bytes here */]);
  /// final credentialId = 'your_credential_id';
  ///
  /// final pkps = PassKeySigner("example", "example.com", "https://example.com");
  /// final passKeySignature = await pkps.signToPasskeySignature(hash, credentialId);
  /// ```
  Future<PassKeySignature> signToPasskeySignature(
      Uint8List hash, String credentialId);
}
