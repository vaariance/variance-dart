part of '../../variance.dart';

class Chain {
  final int chainId;
  final String explorer;
  final EthereumAddress entrypoint;
  final EthereumAddress accountFactory;
  String? ethRpcUrl;
  String? bundlerUrl;

  Chain(
      {required this.chainId,
      required this.explorer,
      this.ethRpcUrl,
      this.bundlerUrl,
      required this.entrypoint,
      required this.accountFactory});

  /// asserts that [ethRpcUrl] and [bundlerUrl] is provided
  Chain validate() {
    require(isURL(ethRpcUrl), "Chain: please provide a valid eth rpc url");
    require(isURL(bundlerUrl), "Chain: please provide a valid bundler url");
    return this;
  }
}

//predefined Chains you can use
class Chains {
  static Map<Network, Chain> chains = {
    // Ethereum Mainnet
    Network.mainnet: Chain(
        chainId: 1,
        explorer: "https://etherscan.io/",
        ethRpcUrl: "https://rpc.ankr.com/eth",
        entrypoint: Constants.entrypoint,
        accountFactory: Constants.accountFactory),
    // Optimism Mainnet
    Network.optimism: Chain(
        chainId: 10,
        explorer: "https://explorer.optimism.io",
        ethRpcUrl: "https://mainnet.optimism.io",
        entrypoint: Constants.entrypoint,
        accountFactory: Constants.accountFactory),
    // Base Mainnet
    Network.base: Chain(
        chainId: 8453,
        explorer: "https://basescan.org",
        ethRpcUrl: "https://mainnet.base.org",
        entrypoint: Constants.entrypoint,
        accountFactory: Constants.accountFactory),
    // Arbitrum (one) Mainnet
    Network.arbitrum: Chain(
        chainId: 42161,
        explorer: "https://arbiscan.io/",
        ethRpcUrl: "https://arb1.arbitrum.io/rpc",
        entrypoint: Constants.entrypoint,
        accountFactory: Constants.accountFactory),
    // Polygon Mainnet
    Network.polygon: Chain(
        chainId: 137,
        explorer: "https://polygonscan.com/",
        ethRpcUrl: "https://polygon-rpc.com/",
        entrypoint: Constants.entrypoint,
        accountFactory: Constants.accountFactory),
    // Mantle Mainnet
    Network.mantle: Chain(
        chainId: 5000,
        explorer: "https://explorer.mantle.xyz/",
        ethRpcUrl: "https://rpc.mantle.xyz/",
        entrypoint: Constants.entrypoint,
        accountFactory: Constants.accountFactory),
    // Sepolia Testnet
    Network.sepolia: Chain(
        chainId: 11155111,
        explorer: "https://sepolia.etherscan.io/",
        ethRpcUrl: "https://rpc.sepolia.org",
        entrypoint: Constants.entrypoint,
        accountFactory: Constants.accountFactory),
    // Optimism Goerli Testnet
    Network.opGoerli: Chain(
        chainId: 420,
        explorer: "https://goerli-explorer.optimism.io",
        ethRpcUrl: "https://goerli.optimism.io",
        entrypoint: Constants.entrypoint,
        accountFactory: Constants.accountFactory),
    // Base Goerli testnet
    Network.baseGoerli: Chain(
        chainId: 84531,
        explorer: "https://goerli.basescan.org",
        ethRpcUrl: "https://goerli.base.org",
        entrypoint: Constants.entrypoint,
        accountFactory: Constants.accountFactory),
    // Mumbai Testnet
    Network.mumbai: Chain(
        chainId: 80001,
        explorer: "https://mumbai.polygonscan.com/",
        ethRpcUrl: "https://rpc-mumbai.maticvigil.com/",
        entrypoint: Constants.entrypoint,
        accountFactory: Constants.accountFactory),
    // Mantle Testnet
    Network.mantleTestnet: Chain(
        chainId: 50001,
        explorer: "https://explorer.testnet.mantle.xyz/",
        ethRpcUrl: "https://rpc.testnet.mantle.xyz/",
        entrypoint: Constants.entrypoint,
        accountFactory: Constants.accountFactory),
    // Scroll Sepolia Testnet
    Network.scrollSepolia: Chain(
        chainId: 534351,
        explorer: "https://sepolia-blockscout.scroll.io/",
        ethRpcUrl: "https://sepolia-rpc.scroll.io/",
        entrypoint: Constants.entrypoint,
        accountFactory: Constants.accountFactory),
    // Localhost
    Network.localhost: Chain(
        chainId: 1337,
        explorer: "http://localhost:8545",
        ethRpcUrl: "http://localhost:8545",
        bundlerUrl: "http://localhost:3000/rpc",
        entrypoint: Constants.entrypoint,
        accountFactory: Constants.accountFactory)
  };

  const Chains._();

  static Chain getChain(Network network) {
    return chains[network]!;
  }
}

class Constants {
  static EthereumAddress entrypoint = EthereumAddress.fromHex(
      "0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789",
      enforceEip55: true);
  static EthereumAddress zeroAddress =
      EthereumAddress.fromHex("0x0000000000000000000000000000000000000000");
  static EthereumAddress accountFactory = EthereumAddress.fromHex(
      "0xCCaE5F64307D86346B83E55e7865f77906F9c7b4",
      enforceEip55: true);
  Constants._();
}

enum Network {
  // mainnet
  mainnet,
  optimism,
  base,
  arbitrum,
  polygon,
  mantle,

  // testnet
  sepolia,
  opGoerli,
  baseGoerli,
  mumbai,
  mantleTestnet,
  scrollSepolia,

  // localhost
  localhost
}
