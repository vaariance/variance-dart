part of '../../utils.dart';

enum CredentialType { hdwallet, privateKey, passkeypair }

class SecureStorageAuthMiddlewareError extends Error {
  final String message =
      "requires auth, but Authentication middleware is not set";

  SecureStorageAuthMiddlewareError();

  @override
  String toString() {
    return 'SecureStorageAuthMiddlewareError: $message';
  }
}

class SecureStorageMiddleware implements SecureStorageRepository {
  final AndroidOptions androidOptions;
  final IOSOptions iosOptions;

  final FlutterSecureStorage secureStorage;
  final Authentication? authMiddleware;

  final String? _credential;

  SecureStorageMiddleware({
    required this.secureStorage,
    this.authMiddleware,
    String? credential,
  })  : androidOptions = const AndroidOptions(
          encryptedSharedPreferences: true,
        ),
        iosOptions = const IOSOptions(
          accessibility: KeychainAccessibility.unlocked,
        ),
        _credential = credential;

  Future<void> _authenticate({required SSAuthOperationOptions options}) async {
    if (!options.requiresAuth) return;
    if (authMiddleware == null) throw SecureStorageAuthMiddlewareError();

    return await authMiddleware?.authenticate(
      localizedReason: options.authReason,
    );
  }

  @override
  Future<void> delete(
    String key, {
    SSAuthOperationOptions? options = const SSAuthOperationOptions(),
  }) async {
    await _authenticate(options: options!);
    await secureStorage.delete(
      key: "${options.ssNameSpace ?? "vaariance"}_$key",
    );
  }

  @override
  Future<String?> read(
    String key, {
    SSAuthOperationOptions? options = const SSAuthOperationOptions(),
  }) async {
    await _authenticate(options: options!);
    return await secureStorage.read(
      key: "${options.ssNameSpace ?? "vaariance"}_$key",
    );
  }

  @override
  Future<String?> readCredential(
    CredentialType type, {
    SSAuthOperationOptions? options = const SSAuthOperationOptions(),
  }) async {
    await _authenticate(options: options!);
    return await secureStorage.read(
      key: "${options.ssNameSpace ?? "vaariance"}_${type.name}",
    );
  }

  @override
  Future<void> save(
    String key,
    String value, {
    SSAuthOperationOptions? options = const SSAuthOperationOptions(),
  }) async {
    await _authenticate(options: options!);
    await secureStorage.write(
      key: "${options.ssNameSpace ?? "vaariance"}_$key",
      value: value,
    );
  }

  @override
  Future<void> saveCredential(
    CredentialType type, {
    SSAuthOperationOptions? options = const SSAuthOperationOptions(),
  }) async {
    await _authenticate(options: options!);
    await secureStorage.write(
      key: "${options.ssNameSpace ?? "vaariance"}_${type.name}",
      value: _credential,
    );
  }

  @override
  Future<void> update(
    String key,
    String value, {
    SSAuthOperationOptions? options = const SSAuthOperationOptions(),
  }) async {
    await _authenticate(options: options!);
    await secureStorage.write(
      key: "${options.ssNameSpace ?? "vaariance"}_$key",
      value: value,
    );
  }
}

class SSAuthOperationOptions {
  final bool requiresAuth;
  final String authReason;
  // Namespace for uniquely addressing the secure storage keys.
  // if provided the secure storage keys will be prefixed with this value, defaults to "vaariance"
  // namespace ?? "vaariance" + "_" + identifier
  final String? ssNameSpace;

  const SSAuthOperationOptions(
      {bool? requiresAuth, String? authReason, this.ssNameSpace})
      : authReason = authReason ?? "unlock to access secure storage",
        requiresAuth = requiresAuth ?? false;
}
