part of 'package:variance_dart/interfaces.dart';

/// A repository for secure storage operations.
///
/// This abstract class defines methods for saving, reading, updating, and
/// deleting key-value pairs in a secure storage medium. The storage operations
/// can optionally require authentication for additional security.
///
/// Subclasses of this abstract class should provide concrete implementations
/// for these methods based on the specific secure storage mechanism they intend
/// to use.
abstract class SecureStorageRepository {
  /// Saves a key-value pair in the secure storage.
  ///
  /// The [key] parameter represents the identifier for the stored value, and
  /// the [value] parameter is the data to be stored. The [options] parameter
  /// encapsulates authentication and other operation-specific options.
  ///
  /// Throws an exception if the operation fails.
  Future<void> save(String key, String value,
      {SSAuthOperationOptions? options});

  /// Saves a credential of the specified type.
  ///
  /// The [type] parameter represents the type of credential to be saved.
  /// The [type] is an enum that defines three types of credentials: `mnemonic`,
  /// `privateKey`, and `passkeypair`. The [options] parameter encapsulates
  /// authentication and other operation-specific options.
  ///
  /// Throws an exception if the operation fails.
  Future<void> saveCredential(CredentialType type,
      {SSAuthOperationOptions? options});

  /// Reads the value associated with the given key from secure storage.
  ///
  /// The [key] parameter represents the identifier for the value to be read.
  /// The [options] parameter encapsulates authentication and other
  /// operation-specific options.
  ///
  /// Returns the stored value if found, otherwise returns `null`.
  ///
  /// Throws an exception if the operation fails.
  Future<String?> read(String key, {SSAuthOperationOptions? options});

  /// Reads a credential of the specified type.
  ///
  /// The [type] parameter represents the type of credential to be read.
  /// The [type] is an enum that defines three types of credentials: `mnemonic`,
  /// `privateKey`, and `passkeypair`. The [options] parameter encapsulates
  /// authentication and other operation-specific options.
  ///
  /// Returns the stored credential if found, otherwise returns `null`.
  ///
  /// Throws an exception if the operation fails.
  Future<String?> readCredential(CredentialType type,
      {SSAuthOperationOptions? options});

  /// Updates the value associated with the given key in secure storage.
  ///
  /// The [key] parameter represents the identifier for the value to be updated,
  /// and the [value] parameter is the new data to be stored. The [options]
  /// parameter encapsulates authentication and other operation-specific options.
  ///
  /// Throws an exception if the operation fails.
  Future<void> update(String key, String value,
      {SSAuthOperationOptions? options});

  /// Deletes the key-value pair associated with the given key from secure storage.
  ///
  /// The [key] parameter represents the identifier for the value to be deleted.
  /// The [options] parameter encapsulates authentication and other
  /// operation-specific options.
  ///
  /// Throws an exception if the operation fails.
  Future<void> delete(String key, {SSAuthOperationOptions? options});
}

abstract class SecureStorage implements FlutterSecureStorage {}
