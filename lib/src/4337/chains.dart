part of '../../variance_dart.dart';

/// Represents an Ethereum-based blockchain chain.
class Chain {
  /// The unique identifier of the chain.
  final int chainId;

  /// The URL of the block explorer for this chain.
  final String explorer;

  /// The address of the EntryPoint contract on this chain.
  final EntryPointAddress entrypoint;

  /// The address of the AccountFactory contract on this chain.
  EthereumAddress? accountFactory;

  /// The URL of the JSON-RPC endpoint for this chain.
  String? jsonRpcUrl;

  /// The URL of the bundler service for this chain.
  String? bundlerUrl;

  /// The URL of the paymaster service for this chain.
  ///
  /// This is an optional parameter and can be left null if the paymaster URL
  /// is not known or needed.
  String? paymasterUrl;

  /// Specify whether it is testnet
  bool testnet;

  /// Creates a new instance of the [Chain] class.
  ///
  /// [chainId] is the unique identifier of the chain.
  /// [explorer] is the URL of the block explorer for this chain.
  /// [entrypoint] is the address of the EntryPoint contract on this chain.
  /// [accountFactory] is the address of the AccountFactory contract on this
  ///   chain.
  /// [jsonRpcUrl] is the URL of the JSON-RPC endpoint for this chain.
  /// [bundlerUrl] is the URL of the bundler service for this chain.
  /// [paymasterUrl] is the optional URL of the paymaster service for this
  ///   chain.
  ///
  /// Example:
  ///
  /// ```dart
  /// final chain = Chain(
  ///   chainId: 1,
  ///   explorer: 'https://etherscan.io',
  ///   entrypoint: EntryPointAddress('0x...'),
  ///   accountFactory: EthereumAddress('0x...'),
  ///   jsonRpcUrl: 'https://mainnet.infura.io/v3/...',
  ///   bundlerUrl: 'https://bundler.example.com',
  ///   paymasterUrl: 'https://paymaster.example.com',
  /// );
  /// ```

  Chain(
      {required this.chainId,
      required this.explorer,
      required this.entrypoint,
      this.accountFactory,
      this.jsonRpcUrl,
      this.bundlerUrl,
      this.paymasterUrl,
      this.testnet = false});
}

//predefined Chains you can use
class Chains {
  static Map<Network, Chain> chains = {
    Network.mainnet: Chain(
      chainId: 1,
      explorer: "https://etherscan.io/",
      jsonRpcUrl: "https://rpc.ankr.com/eth",
      entrypoint: EntryPointAddress.v07,
    ),
    Network.polygon: Chain(
      chainId: 137,
      explorer: "https://polygonscan.com/",
      jsonRpcUrl: "https://rpc.ankr.com/polygon",
      entrypoint: EntryPointAddress.v07,
    ),
    Network.optimism: Chain(
      chainId: 10,
      explorer: "https://explorer.optimism.io",
      jsonRpcUrl: "https://rpc.ankr.com/optimism",
      entrypoint: EntryPointAddress.v07,
    ),
    Network.base: Chain(
      chainId: 8453,
      explorer: "https://basescan.org",
      jsonRpcUrl: "https://rpc.ankr.com/base",
      entrypoint: EntryPointAddress.v07,
    ),
    Network.arbitrum: Chain(
      chainId: 42161,
      explorer: "https://arbiscan.io/",
      jsonRpcUrl: "https://rpc.ankr.com/arbitrum",
      entrypoint: EntryPointAddress.v07,
    ),
    Network.linea: Chain(
      chainId: 59144,
      explorer: "https://lineascan.build/",
      jsonRpcUrl: "https://rpc.linea.build",
      entrypoint: EntryPointAddress.v07,
    ),
    Network.scroll: Chain(
      chainId: 534352,
      explorer: "https://scrollscan.com/",
      jsonRpcUrl: "https://rpc.ankr.com/scroll",
      entrypoint: EntryPointAddress.v07,
    ),
    Network.fuse: Chain(
      chainId: 122,
      explorer: "https://explorer.fuse.io",
      jsonRpcUrl: "https://rpc.fuse.io",
      entrypoint: EntryPointAddress.v07,
    ),
    Network.sepolia: Chain(
        chainId: 11155111,
        explorer: "https://sepolia.etherscan.io/",
        jsonRpcUrl: "https://rpc.ankr.com/eth_sepolia",
        entrypoint: EntryPointAddress.v07,
        testnet: true),
    Network.baseTestnet: Chain(
        chainId: 84532,
        explorer: "https://sepolia.basescan.org/",
        jsonRpcUrl: "https://rpc.ankr.com/base_sepolia",
        entrypoint: EntryPointAddress.v07,
        testnet: true)
  };

  const Chains._();

  /// Returns the [Chain] instance for the given [Network].
  ///
  /// [network] is the target network for which the [Chain] instance is required.
  ///
  /// This method retrieves the [Chain] instance from a predefined map of
  /// networks and their corresponding chain configurations.
  ///
  /// Example:
  ///
  /// ```dart
  /// final mainnetChain = Chain.getChain(Network.ethereum);
  /// final sepoliaChain = Chain.getChain(Network.sepolia);
  /// ```
  static Chain getChain(Network network) {
    return chains[network]!;
  }
}

enum Network {
  // mainnet
  mainnet,
  polygon,
  optimism,
  base,
  arbitrum,
  linea,
  scroll,
  fuse,

  // testnet
  sepolia,
  baseTestnet,
}

/// Represents the address of an EntryPoint contract on the Ethereum blockchain.
class EntryPointAddress {
  /// Returns the EntryPoint address for version 0.6 of the EntryPoint contract.
  static EntryPointAddress get v06 => EntryPointAddress(
        0.6,
        Constants.entrypointv06,
      );

  /// Returns the EntryPoint address for version 0.7 of the EntryPoint contract.
  static EntryPointAddress get v07 => EntryPointAddress(
        0.7,
        Constants.entrypointv07,
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
    Constants.safe4337ModuleAddressv06,
    Constants.safeModuleSetupAddressv06,
  );

  /// The address of the Safe4337Module contract for version 0.7.
  static Safe4337ModuleAddress v07 = Safe4337ModuleAddress(
    0.7,
    Constants.safe4337ModuleAddressv07,
    Constants.safeModuleSetupAddressv07,
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
  factory Safe4337ModuleAddress.fromVersion(double version) {
    switch (version) {
      case 0.6:
        return Safe4337ModuleAddress.v06;
      case 0.7:
        return Safe4337ModuleAddress.v07;
      default:
        throw Exception("Unsupported version: $version");
    }
  }
}

class SafeSingletonAddress {
  static SafeSingletonAddress l1 =
      SafeSingletonAddress(Constants.safeSingletonAddress);

  static SafeSingletonAddress l2 =
      SafeSingletonAddress(Constants.safeL2SingletonAddress);

  static SafeSingletonAddress custom(EthereumAddress address) =>
      SafeSingletonAddress(address);

  final EthereumAddress address;

  SafeSingletonAddress(this.address);
}
