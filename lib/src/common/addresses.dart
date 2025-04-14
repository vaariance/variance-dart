part of '../../variance_dart.dart';

class Addresses {
  static EthereumAddress entrypointv06 =
      EthereumAddress.fromHex("0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789");
  static EthereumAddress entrypointv07 =
      EthereumAddress.fromHex("0x0000000071727De22E5E9d8BAf0edAc6f37da032");
  static EthereumAddress zeroAddress =
      EthereumAddress.fromHex("0x0000000000000000000000000000000000000000");
  static final EthereumAddress lightAccountFactoryAddressv06 =
      EthereumAddress.fromHex("0x00004EC70002a32400f8ae005A26081065620D20");
  static final EthereumAddress lightAccountFactoryAddressv07 =
      EthereumAddress.fromHex("0x0000000000400CdFef5E2714E63d8040b700BC24");
  static final EthereumAddress safeProxyFactoryAddress =
      EthereumAddress.fromHex("0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67");
  static final EthereumAddress safe4337ModuleAddressv06 =
      EthereumAddress.fromHex("0xa581c4A4DB7175302464fF3C06380BC3270b4037");
  static final EthereumAddress safe4337ModuleAddressv07 =
      EthereumAddress.fromHex("0x75cf11467937ce3F2f357CE24ffc3DBF8fD5c226");
  static final EthereumAddress safeSingletonAddress =
      EthereumAddress.fromHex("0x41675C099F32341bf84BFc5382aF534df5C7461a");
  static final EthereumAddress safeL2SingletonAddress =
      EthereumAddress.fromHex("0x29fcB43b46531BcA003ddC8FCB67FFE91900C762");
  static final EthereumAddress safeModuleSetupAddressv06 =
      EthereumAddress.fromHex("0x8EcD4ec46D4D2a6B64fE960B3D64e8B94B2234eb");
  static final EthereumAddress safeModuleSetupAddressv07 =
      EthereumAddress.fromHex("0x2dd68b007B46fBe91B9A7c3EDa5A7a1063cB5b47");
  static final EthereumAddress safeMultiSendaddress =
      EthereumAddress.fromHex("0x38869bf66a61cF6bDB996A6aE40D5853Fd43B526");
  static final EthereumAddress p256VerifierAddress =
      EthereumAddress.fromHex("0x0000000000000000000000000000000000000100");
  static final EthereumAddress sharedSignerAddress =
      EthereumAddress.fromHex("0x94a4F6affBd8975951142c3999aEAB7ecee555c2");

  // !!! Not Confirmed to be the official cannonical address for the safe7579 accross all chains
  static final EthereumAddress safe7579 =
      EthereumAddress.fromHex("0x7579EE8307284F293B1927136486880611F20002");

  Addresses._();
}

/// Represents the address of an EntryPoint contract on the Ethereum blockchain.
class EntryPointAddress {
  /// Returns the EntryPoint address for version 0.6 of the EntryPoint contract.
  static EntryPointAddress get v06 => EntryPointAddress(
        0.6,
        Addresses.entrypointv06,
      );

  /// Returns the EntryPoint address for version 0.7 of the EntryPoint contract.
  static EntryPointAddress get v07 => EntryPointAddress(
        0.7,
        Addresses.entrypointv07,
      );

  /// The version of the EntryPoint contract.
  final double version;

  /// The Ethereum address of the EntryPoint contract.
  final EthereumAddress address;

  /// Creates a new instance of the [EntryPointAddress] class.
  ///
  /// [version] is the version of the EntryPoint contract.
  /// [address] is the Ethereum address of the EntryPoint contract.
  const EntryPointAddress(this.version, this.address);
}

/// Represents the address of the Safe4337Module contract on the Ethereum blockchain.
class Safe4337ModuleAddress {
  /// The address of the Safe4337Module contract for version 0.6.
  static Safe4337ModuleAddress v06 = Safe4337ModuleAddress(
    0.6,
    Addresses.safe4337ModuleAddressv06,
    Addresses.safeModuleSetupAddressv06,
  );

  /// The address of the Safe4337Module contract for version 0.7.
  static Safe4337ModuleAddress v07 = Safe4337ModuleAddress(
    0.7,
    Addresses.safe4337ModuleAddressv07,
    Addresses.safeModuleSetupAddressv07,
  );

  static Safe4337ModuleAddress v07_7579 = Safe4337ModuleAddress(
    0.7,
    Addresses.safe7579,
    Addresses.zeroAddress,
  );

  /// The version of the Safe4337Module contract.
  final double version;

  /// The Ethereum address of the Safe4337Module contract.
  final EthereumAddress address;

  /// The address of the SafeModuleSetup contract.
  final EthereumAddress setup;

  /// Creates a new instance of the [Safe4337ModuleAddress] class.
  ///
  /// [version] is the version of the Safe4337Module contract.
  /// [address] is the Ethereum address of the Safe4337Module contract.
  /// [setup] is the address of the SafeModuleSetup contract.
  const Safe4337ModuleAddress(this.version, this.address, this.setup);

  /// Creates a new instance of the [Safe4337ModuleAddress] class from a given version.
  ///
  /// [version] is the version of the Safe4337Module contract.
  ///
  /// If the provided version is not supported, an [Exception] will be thrown.
  ///
  /// Example:
  ///
  /// ```dart
  /// final moduleAddress = Safe4337ModuleAddress.fromVersion(0.6);
  /// ```
  factory Safe4337ModuleAddress.fromVersion(double version,
      {bool safe7579 = false}) {
    switch (version) {
      case 0.6:
        return Safe4337ModuleAddress.v06;
      case 0.7:
        return safe7579
            ? Safe4337ModuleAddress.v07_7579
            : Safe4337ModuleAddress.v07;
      default:
        throw Exception("Unsupported version: $version");
    }
  }
}

class SafeSingletonAddress {
  static SafeSingletonAddress l1 =
      SafeSingletonAddress(Addresses.safeSingletonAddress);

  static SafeSingletonAddress l2 =
      SafeSingletonAddress(Addresses.safeL2SingletonAddress);

  final EthereumAddress address;

  SafeSingletonAddress(this.address);

  static SafeSingletonAddress custom(EthereumAddress address) =>
      SafeSingletonAddress(address);
}
