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

  Chain({
    required this.chainId,
    required this.explorer,
    required this.entrypoint,
    this.accountFactory,
    this.jsonRpcUrl,
    this.bundlerUrl,
    this.paymasterUrl,
    this.testnet = false,
  });
}

//predefined Chains you can use
class Chains {
  static final Map<Network, Chain> _chains = {
    Network.mainnet: Chain(
      chainId: 1,
      explorer: "https://etherscan.io/",
      entrypoint: EntryPointAddress.v07,
    ),
    Network.polygon: Chain(
      chainId: 137,
      explorer: "https://polygonscan.com/",
      entrypoint: EntryPointAddress.v07,
    ),
    Network.optimism: Chain(
      chainId: 10,
      explorer: "https://explorer.optimism.io",
      entrypoint: EntryPointAddress.v07,
    ),
    Network.base: Chain(
      chainId: 8453,
      explorer: "https://basescan.org",
      entrypoint: EntryPointAddress.v07,
    ),
    Network.arbitrum: Chain(
      chainId: 42161,
      explorer: "https://arbiscan.io/",
      entrypoint: EntryPointAddress.v07,
    ),
    Network.linea: Chain(
      chainId: 59144,
      explorer: "https://lineascan.build/",
      entrypoint: EntryPointAddress.v07,
    ),
    Network.scroll: Chain(
      chainId: 534352,
      explorer: "https://scrollscan.com/",
      entrypoint: EntryPointAddress.v07,
    ),
    Network.fuse: Chain(
      chainId: 122,
      explorer: "https://explorer.fuse.io",
      entrypoint: EntryPointAddress.v07,
    ),
    Network.sepolia: Chain(
      chainId: 11155111,
      explorer: "https://sepolia.etherscan.io/",
      entrypoint: EntryPointAddress.v07,
      testnet: true,
    ),
    Network.baseTestnet: Chain(
      chainId: 84532,
      explorer: "https://sepolia.basescan.org/",
      entrypoint: EntryPointAddress.v07,
      testnet: true,
    ),
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
    return _chains[network]!;
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
