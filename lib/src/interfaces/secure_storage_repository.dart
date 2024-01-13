part of 'interfaces.dart';

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
  /// Saves a key-value pair to the secure storage.
  ///
  /// Parameters:
  /// - [key]: The key under which to store the value.
  /// - [value]: The value to be stored.
  /// - [options]: Options for the secure storage operation, including authentication requirements.
  ///
  /// Throws a [SecureStorageAuthMiddlewareError] if authentication is required but no authentication middleware is provided.
  ///
  /// Example:
  /// ```dart
  /// final saveKey = 'myKey';
  /// final saveValue = 'myValue';
  /// final saveOptions = SSAuthOperationOptions(
  ///   requiresAuth: true,
  ///   authReason: 'Authenticate to save the key-value pair.',
  ///   ssNameSpace: 'myNamespace',
  /// );
  /// await save(saveKey, saveValue, options: saveOptions);
  /// print('Key-value pair saved successfully.');
  /// ```
  Future<void> save(String key, String value,
      {SSAuthOperationOptions? options});

  /// Saves a credential to the secure storage for a specified [CredentialType].
  ///
  /// Parameters:
  /// - [type]: The type of credential to be saved.
  /// - [options]: Options for the secure storage operation, including authentication requirements.
  ///
  /// Throws a [SecureStorageAuthMiddlewareError] if authentication is required but no authentication middleware is provided.
  ///
  /// Example:
  /// ```dart
  /// final saveCredentialType = CredentialType.exampleCredential;
  /// final saveOptions = SSAuthOperationOptions(
  ///   requiresAuth: true,
  ///   authReason: 'Authenticate to save the credential.',
  ///   ssNameSpace: 'myNamespace',
  /// );
  /// await saveCredential(saveCredentialType, options: saveOptions);
  /// print('Credential saved successfully.');
  /// ```
  Future<void> saveCredential(CredentialType type,
      {SSAuthOperationOptions? options});

  /// Reads a value from the secure storage.
  ///
  /// Parameters:
  /// - [key]: The key for the value to be read.
  /// - [options]: Options for the secure storage operation, including authentication requirements.
  ///
  /// Throws a [SecureStorageAuthMiddlewareError] if authentication is required but no authentication middleware is provided.
  ///
  /// Returns the value associated with the provided key, or `null` if the key is not found.
  ///
  /// Example:
  /// ```dart
  /// final keyToRead = 'exampleKey';
  /// final readOptions = SSAuthOperationOptions(
  ///   requiresAuth: true,
  ///   authReason: 'Authenticate to read the key.',
  ///   ssNameSpace: 'myNamespace',
  /// );
  /// final storedValue = await read(keyToRead, options: readOptions);
  /// print('Stored value: $storedValue');
  /// ```
  Future<String?> read(String key, {SSAuthOperationOptions? options});

  /// Reads a credential from the secure storage.
  ///
  /// Parameters:
  /// - [type]: The type of credential to be read.
  /// - [options]: Options for the secure storage operation, including authentication requirements.
  ///
  /// Throws a [SecureStorageAuthMiddlewareError] if authentication is required but no authentication middleware is provided.
  ///
  /// Returns the credential associated with the provided type, or `null` if the credential is not found.
  ///
  /// Example:
  /// ```dart
  /// final credentialType = CredentialType.hdwallet;
  /// final readOptions = SSAuthOperationOptions(
  ///   requiresAuth: true,
  ///   authReason: 'Authenticate to read the credential.',
  ///   ssNameSpace: 'myNamespace',
  /// );
  /// final storedCredential = await readCredential(credentialType, options: readOptions);
  /// print('Stored credential: $storedCredential');
  /// ```
  Future<String?> readCredential(CredentialType type,
      {SSAuthOperationOptions? options});

  /// Updates the value of an existing key in the secure storage.
  ///
  /// Parameters:
  /// - [key]: The key for which to update the value.
  /// - [value]: The new value to be stored.
  /// - [options]: Options for the secure storage operation, including authentication requirements.
  ///
  /// Throws a [SecureStorageAuthMiddlewareError] if authentication is required but no authentication middleware is provided.
  ///
  /// Example:
  /// ```dart
  /// final updateKey = 'myKey';
  /// final updateValue = 'newValue';
  /// final updateOptions = SSAuthOperationOptions(
  ///   requiresAuth: true,
  ///   authReason: 'Authenticate to update the key value.',
  ///   ssNameSpace: 'myNamespace',
  /// );
  /// await update(updateKey, updateValue, options: updateOptions);
  /// print('Key updated successfully.');
  /// ```
  Future<void> update(String key, String value,
      {SSAuthOperationOptions? options});

  /// Deletes a key from the secure storage.
  ///
  /// Parameters:
  /// - [key]: The key to be deleted.
  /// - [options]: Options for the secure storage operation, including authentication requirements.
  ///
  /// Throws a [SecureStorageAuthMiddlewareError] if authentication is required but no authentication middleware is provided.
  ///
  /// Example:
  /// ```dart
  /// final keyToDelete = 'exampleKey';
  /// final deleteOptions = SSAuthOperationOptions(
  ///   requiresAuth: true,
  ///   authReason: 'Authenticate to delete the key.',
  ///   ssNameSpace: 'myNamespace',
  /// );
  /// await delete(keyToDelete, options: deleteOptions);
  /// ```
  Future<void> delete(String key, {SSAuthOperationOptions? options});
}
