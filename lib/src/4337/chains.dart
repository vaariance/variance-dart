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
      this.paymasterUrl});
}

//predefined Chains you can use
class Chains {
  static Map<Network, Chain> chains = {
    Network.ethereum: Chain(
      chainId: 1,
      explorer: "https://etherscan.io/",
      jsonRpcUrl: "https://rpc.ankr.com/eth",
      entrypoint: EntryPointAddress.v06,
    ),
    Network.polygon: Chain(
      chainId: 137,
      explorer: "https://polygonscan.com/",
      jsonRpcUrl: "https://rpc.ankr.com/polygon",
      entrypoint: EntryPointAddress.v06,
    ),
    Network.optimism: Chain(
      chainId: 10,
      explorer: "https://explorer.optimism.io",
      jsonRpcUrl: "https://rpc.ankr.com/optimism",
      entrypoint: EntryPointAddress.v06,
    ),
    Network.base: Chain(
      chainId: 8453,
      explorer: "https://basescan.org",
      jsonRpcUrl: "https://rpc.ankr.com/base",
      entrypoint: EntryPointAddress.v06,
    ),
    Network.arbitrumOne: Chain(
      chainId: 42161,
      explorer: "https://arbiscan.io/",
      jsonRpcUrl: "https://rpc.ankr.com/arbitrum",
      entrypoint: EntryPointAddress.v06,
    ),
    Network.linea: Chain(
        chainId: 59144,
        explorer: "https://lineascan.build/",
        jsonRpcUrl: "https://rpc.linea.build",
        entrypoint: EntryPointAddress.v06),
    Network.opBnB: Chain(
      chainId: 204,
      explorer: "http://opbnbscan.com/",
      jsonRpcUrl: "https://opbnb-mainnet-rpc.bnbchain.org",
      entrypoint: EntryPointAddress.v06,
    ),
    Network.scroll: Chain(
      chainId: 534352,
      explorer: "https://scrollscan.com/",
      jsonRpcUrl: "https://rpc.ankr.com/scroll",
      entrypoint: EntryPointAddress.v06,
    ),
    Network.sepolia: Chain(
      chainId: 11155111,
      explorer: "https://sepolia.etherscan.io/",
      jsonRpcUrl: "https://rpc.ankr.com/eth_sepolia",
      entrypoint: EntryPointAddress.v06,
    ),
    Network.mumbai: Chain(
      chainId: 80001,
      explorer: "https://mumbai.polygonscan.com/",
      jsonRpcUrl: "https://rpc.ankr.com/polygon_mumbai",
      entrypoint: EntryPointAddress.v06,
    ),
    Network.baseTestnet: Chain(
      chainId: 84532,
      explorer: "https://sepolia.basescan.org/",
      jsonRpcUrl: "https://rpc.ankr.com/base_sepolia",
      entrypoint: EntryPointAddress.v06,
    ),
    Network.localhost: Chain(
      chainId: 1337,
      explorer: "http://localhost:8545",
      jsonRpcUrl: "http://localhost:8545",
      bundlerUrl: "http://localhost:3000/rpc",
      entrypoint: EntryPointAddress.v06,
    )
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

class Constants {
  static EthereumAddress entrypointv06 =
      EthereumAddress.fromHex("0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789");
  static EthereumAddress entrypointv07 =
      EthereumAddress.fromHex("0x0000000071727De22E5E9d8BAf0edAc6f37da032");
  static EthereumAddress zeroAddress =
      EthereumAddress.fromHex("0x0000000000000000000000000000000000000000");
  static final EthereumAddress simpleAccountFactoryAddress =
      EthereumAddress.fromHex("0x9406Cc6185a346906296840746125a0E44976454");
  static final EthereumAddress safeProxyFactoryAddress =
      EthereumAddress.fromHex("0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67");
  static final EthereumAddress safe4337ModuleAddress =
      EthereumAddress.fromHex("0xa581c4A4DB7175302464fF3C06380BC3270b4037");
  static final EthereumAddress safeSingletonAddress =
      EthereumAddress.fromHex("0x41675C099F32341bf84BFc5382aF534df5C7461a");
  static final EthereumAddress safeModuleSetupAddress =
      EthereumAddress.fromHex("0x8EcD4ec46D4D2a6B64fE960B3D64e8B94B2234eb");
  static final EthereumAddress safeMultiSendaddress =
      EthereumAddress.fromHex("0x38869bf66a61cF6bDB996A6aE40D5853Fd43B526");

  Constants._();
}

enum Network {
  // mainnet
  ethereum,
  polygon,
  optimism,
  base,
  arbitrumOne,
  linea,
  opBnB,
  scroll,

  // testnet
  sepolia,
  mumbai,
  baseTestnet,

  // localhost
  localhost
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
    Constants.safe4337ModuleAddress,
  );

  /// The version of the Safe4337Module contract.
  final double version;

  /// The Ethereum address of the Safe4337Module contract.
  final EthereumAddress address;

  /// Creates a new instance of the [Safe4337ModuleAddress] class.
  ///
  /// [version] is the version of the Safe4337Module contract.
  /// [address] is the Ethereum address of the Safe4337Module contract.
  const Safe4337ModuleAddress(this.version, this.address);

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
      default:
        throw Exception("Unsupported version: $version");
    }
  }
}
