part of '../../utils.dart';

class AuthenticationError extends Error {
  final String message;

  AuthenticationError(this.message);
}

class AuthenticationMiddleware implements Authentication {
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  Future<void> authenticate(
      {required String localizedReason,
      AndroidAuthMessages? androidAuthMessages,
      IOSAuthMessages? iosAuthMessages,
      bool useErrorDialogs = true,
      bool stickyAuth = true}) async {
    final bool canAuthenticate = await canAuthenticateWithBiometrics();

    if (!canAuthenticate) {
      throw AuthenticationError(
          'Unable to authenticate with biometrics: NO BIOMETRICS ENROLLED');
    }

    try {
      final bool authenticated = await _auth.authenticate(
          localizedReason: localizedReason,
          options: AuthenticationOptions(
            useErrorDialogs: useErrorDialogs,
            stickyAuth: stickyAuth,
            biometricOnly: true,
          ),
          authMessages: <AuthMessages>[
            androidAuthMessages ??
                const AndroidAuthMessages(
                  signInTitle: 'Authentication required!',
                  cancelButton: 'No thanks',
                ),
            iosAuthMessages ??
                const IOSAuthMessages(
                  cancelButton: 'No thanks',
                ),
          ]);

      if (!authenticated) {
        throw AuthenticationError(
            'Unable to authenticate with biometrics: AUTHENTICATION FAILED');
      }
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        throw AuthenticationError(
            'Unable to authenticate with biometrics: NOT AVAILABLE');
      } else if (e.code == auth_error.notEnrolled) {
        throw AuthenticationError(
            'Unable to authenticate with biometrics: NOT ENROLLED');
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        throw AuthenticationError(
            'Unable to authenticate with biometrics: LOCKED OUT');
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<bool> canAuthenticateWithBiometrics() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

    if (!canAuthenticate) {
      throw AuthenticationError(
          'Unable to authenticate with biometrics: BIOMETRICS NOT SUPPORTED');
    }

    final List<BiometricType> availableBiometrics =
        await _auth.getAvailableBiometrics();

    return availableBiometrics.isNotEmpty;
  }
}
