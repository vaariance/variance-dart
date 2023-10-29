import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:web3dart/credentials.dart';

enum Chain {
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

class Chains {
  static EthereumAddress entrypoint = EthereumAddress.fromHex(
      "0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789",
      enforceEip55: true);
  static EthereumAddress zeroAddress =
      EthereumAddress.fromHex("0x0000000000000000000000000000000000000000");
  static EthereumAddress accountFactory = EthereumAddress.fromHex(
      "0xCCaE5F64307D86346B83E55e7865f77906F9c7b4",
      enforceEip55: true);

  static Map<Chain, IChain> chains = {
    // Ethereum Mainnet
    Chain.mainnet: IChain(
        chainId: 1,
        explorer: "https://etherscan.io/",
        rpcUrl: "https://rpc.ankr.com/eth",
        entrypoint: entrypoint,
        accountFactory: accountFactory),
    // Optimism Mainnet
    Chain.optimism: IChain(
        chainId: 10,
        explorer: "https://explorer.optimism.io",
        rpcUrl: "https://mainnet.optimism.io",
        entrypoint: entrypoint,
        accountFactory: accountFactory),
    // Base Mainnet
    Chain.base: IChain(
        chainId: 8453,
        explorer: "https://basescan.org",
        rpcUrl: "https://mainnet.base.org",
        entrypoint: entrypoint,
        accountFactory: accountFactory),
    // Arbitrum (one) Mainnet
    Chain.arbitrum: IChain(
        chainId: 42161,
        explorer: "https://arbiscan.io/",
        rpcUrl: "https://arb1.arbitrum.io/rpc",
        entrypoint: entrypoint,
        accountFactory: accountFactory),
    // Polygon Mainnet
    Chain.polygon: IChain(
        chainId: 137,
        explorer: "https://polygonscan.com/",
        rpcUrl: "https://polygon-rpc.com/",
        entrypoint: entrypoint,
        accountFactory: accountFactory),
    // Mantle Mainnet
    Chain.mantle: IChain(
        chainId: 5000,
        explorer: "https://explorer.mantle.xyz/",
        rpcUrl: "https://rpc.mantle.xyz/",
        entrypoint: entrypoint,
        accountFactory: accountFactory),
    // Sepolia Testnet
    Chain.sepolia: IChain(
        chainId: 11155111,
        explorer: "https://sepolia.etherscan.io/",
        rpcUrl: "https://rpc.sepolia.org",
        entrypoint: entrypoint,
        accountFactory: accountFactory),
    // Optimism Goerli Testnet
    Chain.opGoerli: IChain(
        chainId: 420,
        explorer: "https://goerli-explorer.optimism.io",
        rpcUrl: "https://goerli.optimism.io",
        entrypoint: entrypoint,
        accountFactory: accountFactory),
    // Base Goerli testnet
    Chain.baseGoerli: IChain(
        chainId: 84531,
        explorer: "https://goerli.basescan.org",
        rpcUrl: "https://goerli.base.org",
        entrypoint: entrypoint,
        accountFactory: accountFactory),
    // Mumbai Testnet
    Chain.mumbai: IChain(
        chainId: 80001,
        explorer: "https://mumbai.polygonscan.com/",
        rpcUrl: "https://rpc-mumbai.maticvigil.com/",
        entrypoint: entrypoint,
        accountFactory: accountFactory),
    // Mantle Testnet
    Chain.mantleTestnet: IChain(
        chainId: 50001,
        explorer: "https://explorer.testnet.mantle.xyz/",
        rpcUrl: "https://rpc.testnet.mantle.xyz/",
        entrypoint: entrypoint,
        accountFactory: accountFactory),
    // Scroll Sepolia Testnet
    Chain.scrollSepolia: IChain(
        chainId: 534351,
        explorer: "https://sepolia-blockscout.scroll.io/",
        rpcUrl: "https://sepolia-rpc.scroll.io/",
        entrypoint: entrypoint,
        accountFactory: accountFactory),
    // Localhost
    Chain.localhost: IChain(
        chainId: 1337,
        explorer: "http://localhost:8545",
        rpcUrl: "http://localhost:8545",
        entrypoint: entrypoint,
        bundlerUrl: "http://localhost:3000/rpc",
        accountFactory: accountFactory)
  };

  const Chains._();

  static IChain getChain(Chain network) {
    return chains[network]!;
  }
}

///[IChain]
///
/// Holds information about a chain
///
/// and allows for wallet to interact with different chains
class IChain {
  final int chainId;
  final String explorer;
  final EthereumAddress entrypoint;
  final EthereumAddress accountFactory;
  String? rpcUrl;
  String? bundlerUrl;

  IChain(
      {required this.chainId,
      required this.explorer,
      this.rpcUrl,
      this.bundlerUrl,
      required this.entrypoint,
      required this.accountFactory});

  /// asserts that [rpcUrl] and [bundlerUrl] is provided
  IChain validate() {
    require(rpcUrl != null && rpcUrl!.isNotEmpty,
        "Chain: please provide a valid url for rpcUrl");
    require(bundlerUrl != null && bundlerUrl!.isNotEmpty,
        "Chain: please provide a valid url for bundlerUrl");
    return this;
  }
}
