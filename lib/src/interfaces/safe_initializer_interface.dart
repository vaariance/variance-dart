// In a shared package or location
part of '../../variance_dart.dart';

abstract class SafeInitializerInterface {
  Iterable<EthereumAddress> get owners;
  int get threshold;
  Safe4337ModuleAddress get module;
  SafeSingletonAddress get singleton;
  Uint8List Function(Uint8List Function())? get encodeWebauthnSetup;

  Uint8List getInitializer();
}

abstract class Safe7579InitializerInterface extends SafeInitializerInterface {
  EthereumAddress get launchpad;
  Iterable<ModuleInit>? get validators;
  Iterable<ModuleInit>? get executors;
  Iterable<ModuleInit>? get fallbacks;
  Iterable<ModuleInit>? get hooks;
  Iterable<EthereumAddress>? get attesters;
  int? get attestersThreshold;
}
