// In a shared package or location
part of '../../variance_dart.dart';

abstract class SafeInitializer {
  /// The list of owner addresses for the Safe.
  Iterable<EthereumAddress> get owners;

  /// The number of required confirmations for a Safe transaction.
  int get threshold;

  /// The 4337 module address.
  Safe4337ModuleAddress get module;

  /// The Safe singleton address.
  SafeSingletonAddress get singleton;

  /// Optional WebAuthn setup encoding function.
  Uint8List Function(Uint8List Function())? get encodeWebauthnSetup;

  /// Generates the initializer data for deploying a new Safe contract.
  ///
  /// Returns a [Uint8List] containing the encoded initializer data.
  Uint8List getInitializer();
}
