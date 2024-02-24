part of '../../variance.dart';

class Chain {
  final int chainId;
  final String explorer;
  final EthereumAddress entrypoint;
  EthereumAddress? accountFactory;
  String? ethRpcUrl;
  String? bundlerUrl;
  String? paymasterUrl;

  Chain(
      {required this.chainId,
      required this.explorer,
      required this.entrypoint,
      this.accountFactory,
      this.ethRpcUrl,
      this.bundlerUrl,
      this.paymasterUrl});

  /// asserts that [ethRpcUrl] and [bundlerUrl] is provided
  Chain validate() {
    require(isURL(ethRpcUrl),
        "Chain Config Error: please provide a valid eth rpc url");
    require(isURL(bundlerUrl),
        "Chain Config Error: please provide a valid bundler url");
    require(accountFactory != null,
        "Chain Config Error: please provide account factory address");
    return this;
  }
}

//predefined Chains you can use
class Chains {
  static Map<Network, Chain> chains = {
    Network.ethereum: Chain(
      chainId: 1,
      explorer: "https://etherscan.io/",
      ethRpcUrl: "https://rpc.ankr.com/eth",
      entrypoint: Constants.entrypointv06,
    ),
    Network.polygon: Chain(
      chainId: 137,
      explorer: "https://polygonscan.com/",
      ethRpcUrl: "https://polygon-rpc.com/",
      entrypoint: Constants.entrypointv06,
    ),
    Network.optimism: Chain(
      chainId: 10,
      explorer: "https://explorer.optimism.io",
      ethRpcUrl: "https://mainnet.optimism.io",
      entrypoint: Constants.entrypointv06,
    ),
    Network.base: Chain(
      chainId: 8453,
      explorer: "https://basescan.org",
      ethRpcUrl: "https://mainnet.base.org",
      entrypoint: Constants.entrypointv06,
    ),
    Network.arbitrumOne: Chain(
      chainId: 42161,
      explorer: "https://arbiscan.io/",
      ethRpcUrl: "https://arb1.arbitrum.io/rpc",
      entrypoint: Constants.entrypointv06,
    ),
    Network.mantle: Chain(
      chainId: 5000,
      explorer: "https://explorer.mantle.xyz/",
      ethRpcUrl: "https://rpc.mantle.xyz/",
      entrypoint: Constants.entrypointv06,
    ),
    Network.linea: Chain(
        chainId: 59144,
        explorer: "https://lineascan.build/",
        ethRpcUrl: "https://rpc.linea.build",
        entrypoint: Constants.entrypointv06),
    Network.avalanche: Chain(
      chainId: 43114,
      explorer: "https://snowtrace.io/",
      ethRpcUrl: "https://api.avax.network/ext/bc/C/rpc",
      entrypoint: Constants.entrypointv06,
    ),
    Network.gnosis: Chain(
      chainId: 100,
      explorer: "https://gnosisscan.io/",
      ethRpcUrl: "https://rpc.ankr.com/gnosis",
      entrypoint: Constants.entrypointv06,
    ),
    Network.celo: Chain(
      chainId: 42220,
      explorer: "https://celoscan.io/",
      ethRpcUrl: "https://forno.celo.org",
      entrypoint: Constants.entrypointv06,
    ),
    Network.fantom: Chain(
      chainId: 250,
      explorer: "https://ftmscan.com/",
      ethRpcUrl: "https://rpc.fantom.network",
      entrypoint: Constants.entrypointv06,
    ),
    Network.opBnB: Chain(
      chainId: 204,
      explorer: "http://opbnbscan.com/",
      ethRpcUrl: "https://opbnb-mainnet-rpc.bnbchain.org",
      entrypoint: Constants.entrypointv06,
    ),
    Network.arbitrumNova: Chain(
      chainId: 42170,
      explorer: "https://nova.arbiscan.io/",
      ethRpcUrl: "https://nova.arbitrum.io/rpc",
      entrypoint: Constants.entrypointv06,
    ),
    Network.polygonzkEvm: Chain(
      chainId: 1101,
      explorer: "https://zkevm.polygonscan.com/",
      ethRpcUrl: "https://polygonzkevm-mainnet.g.alchemy.com/v2/demo",
      entrypoint: Constants.entrypointv06,
    ),
    Network.scroll: Chain(
      chainId: 534352,
      explorer: "https://scrollscan.com/",
      ethRpcUrl: "https://rpc.scroll.io/",
      entrypoint: Constants.entrypointv06,
    ),
    Network.mode: Chain(
      chainId: 34443,
      explorer: "https://explorer.mode.network/",
      ethRpcUrl: "https://mainnet.mode.network/",
      entrypoint: Constants.entrypointv06,
    ),
    Network.sepolia: Chain(
      chainId: 11155111,
      explorer: "https://sepolia.etherscan.io/",
      ethRpcUrl: "https://rpc.sepolia.org",
      entrypoint: Constants.entrypointv06,
    ),
    Network.mumbai: Chain(
      chainId: 80001,
      explorer: "https://mumbai.polygonscan.com/",
      ethRpcUrl: "https://rpc-mumbai.maticvigil.com/",
      entrypoint: Constants.entrypointv06,
    ),
    Network.baseTestent: Chain(
      chainId: 84531,
      explorer: "https://sepolia.basescan.org",
      ethRpcUrl: "https://api-sepolia.basescan.org/api",
      entrypoint: Constants.entrypointv06,
    ),
    Network.fuji: Chain(
      chainId: 43113,
      explorer: "https://testnet.snowtrace.io/",
      ethRpcUrl: "https://api.avax-test.network/ext/bc/C/rpc",
      entrypoint: Constants.entrypointv06,
    ),
    Network.katla: Chain(
      chainId: 167008,
      explorer: "https://explorer.katla.taiko.xyz/",
      ethRpcUrl: "https://rpc.katla.taiko.xyz",
      entrypoint: Constants.entrypointv06,
    ),
    Network.localhost: Chain(
      chainId: 1337,
      explorer: "http://localhost:8545",
      ethRpcUrl: "http://localhost:8545",
      bundlerUrl: "http://localhost:3000/rpc",
      entrypoint: Constants.entrypointv06,
    )
  };

  const Chains._();

  static Chain getChain(Network network) {
    return chains[network]!;
  }
}

class Constants {
  static EthereumAddress entrypointv06 =
      EthereumAddress.fromHex("0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789");
  static EthereumAddress entrypoint =
      EthereumAddress.fromHex("0x0000000071727De22E5E9d8BAf0edAc6f37da032");
  static EthereumAddress zeroAddress =
      EthereumAddress.fromHex("0x0000000000000000000000000000000000000000");

  Constants._();
}

enum Network {
  // mainnet
  ethereum,
  polygon,
  optimism,
  base,
  arbitrumOne,
  mantle,
  linea,
  avalanche,
  gnosis,
  celo,
  fantom,
  opBnB,
  arbitrumNova,
  polygonzkEvm,
  scroll,
  mode,

  // testnet
  sepolia,
  mumbai,
  baseTestent,
  fuji,
  katla,

  // localhost
  localhost
}
