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

/// Abstract implementation providing base functionality for Safe initializers.
/// This serves as a middle layer that concrete implementations can extend.
abstract class BaseSafeInitializer implements SafeInitializer {
  @override
  final Iterable<EthereumAddress> owners;

  @override
  final int threshold;

  @override
  final Safe4337ModuleAddress module;

  @override
  final SafeSingletonAddress singleton;

  @override
  final Uint8List Function(Uint8List Function())? encodeWebauthnSetup;

  BaseSafeInitializer({
    required this.owners,
    required this.threshold,
    required this.module,
    required this.singleton,
    this.encodeWebauthnSetup,
  });

  /// Default implementation of getInitializer that can be overridden by subclasses.
  @override
  Uint8List getInitializer() {
    encodeModuleSetup() {
      return Contract.encodeFunctionCall(
          "enableModules", module.setup, ContractAbis.get("enableModules"), [
        [module.address]
      ]);
    }

    final setup = {
      "owners": owners.toList(),
      "threshold": BigInt.from(threshold),
      "to": null,
      "data": null,
      "fallbackHandler": module.address,
    };

    if (encodeWebauthnSetup != null) {
      setup["to"] = Addresses.safeMultiSendaddress;
      setup["data"] = encodeWebauthnSetup!(encodeModuleSetup);
    } else {
      setup["to"] = module.setup;
      setup["data"] = encodeModuleSetup();
    }

    return Contract.encodeFunctionCall(
        "setup", singleton.address, ContractAbis.get("setup"), [
      setup["owners"],
      setup["threshold"],
      setup["to"],
      setup["data"],
      setup["fallbackHandler"],
      Addresses.zeroAddress,
      BigInt.zero,
      Addresses.zeroAddress,
    ]);
  }
}
