part of 'package:variance_dart/interfaces.dart';

/// An abstract class representing authentication operations.
///
/// Subclasses of this abstract class should provide concrete implementations
/// for authentication mechanisms on specific platforms.
abstract class Authentication {
  /// Performs an authentication operation.
  ///
  /// The authentication operation may involve displaying a prompt to the user
  /// for providing authentication credentials, such as a password, fingerprint,
  /// or face recognition.
  ///
  /// The [localizedReason] parameter is a human-readable message describing
  /// why authentication is required. The [androidAuthMessages] and [iosAuthMessages]
  /// parameters allow providing custom strings for platform-specific authentication
  /// scenarios.
  ///
  /// The [useErrorDialogs] parameter, when set to `true`, indicates that error
  /// dialogs should be used to communicate authentication failures. The
  /// [stickyAuth] parameter, when set to `true`, allows maintaining the
  /// authentication state across app launches.
  ///
  /// Throws an exception if the authentication operation fails.
  Future<void> authenticate({
    required String localizedReason,
    AndroidAuthMessages? androidAuthMessages,
    IOSAuthMessages? iosAuthMessages,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  });

  /// Checks whether the device supports biometric authentication.
  ///
  /// This method determines whether the device has the necessary hardware and
  /// configuration to perform biometric authentication, such as fingerprint or
  /// face recognition.
  ///
  /// Returns `true` if biometric authentication is supported; otherwise,
  /// returns `false`.
  ///
  /// Throws an exception if there is an error while determining biometric
  /// authentication support.
  Future<bool> canAuthenticateWithBiometrics();
}
