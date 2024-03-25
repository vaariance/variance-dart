part of '../../variance.dart';

class Chain {
  final int chainId;
  final String explorer;
  final EntryPoint entrypoint;
  EthereumAddress? accountFactory;
  String? jsonRpcUrl;
  String? bundlerUrl;
  String? paymasterUrl;

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
      entrypoint: EntryPoint.v06,
    ),
    Network.polygon: Chain(
      chainId: 137,
      explorer: "https://polygonscan.com/",
      jsonRpcUrl: "https://polygon-rpc.com/",
      entrypoint: EntryPoint.v06,
    ),
    Network.optimism: Chain(
      chainId: 10,
      explorer: "https://explorer.optimism.io",
      jsonRpcUrl: "https://mainnet.optimism.io",
      entrypoint: EntryPoint.v06,
    ),
    Network.base: Chain(
      chainId: 8453,
      explorer: "https://basescan.org",
      jsonRpcUrl: "https://mainnet.base.org",
      entrypoint: EntryPoint.v06,
    ),
    Network.arbitrumOne: Chain(
      chainId: 42161,
      explorer: "https://arbiscan.io/",
      jsonRpcUrl: "https://arb1.arbitrum.io/rpc",
      entrypoint: EntryPoint.v06,
    ),
    Network.linea: Chain(
        chainId: 59144,
        explorer: "https://lineascan.build/",
        jsonRpcUrl: "https://rpc.linea.build",
        entrypoint: EntryPoint.v06),
    Network.opBnB: Chain(
      chainId: 204,
      explorer: "http://opbnbscan.com/",
      jsonRpcUrl: "https://opbnb-mainnet-rpc.bnbchain.org",
      entrypoint: EntryPoint.v06,
    ),
    Network.scroll: Chain(
      chainId: 534352,
      explorer: "https://scrollscan.com/",
      jsonRpcUrl: "https://rpc.scroll.io/",
      entrypoint: EntryPoint.v06,
    ),
    Network.sepolia: Chain(
      chainId: 11155111,
      explorer: "https://sepolia.etherscan.io/",
      jsonRpcUrl: "https://rpc.sepolia.org",
      entrypoint: EntryPoint.v06,
    ),
    Network.mumbai: Chain(
      chainId: 80001,
      explorer: "https://mumbai.polygonscan.com/",
      jsonRpcUrl: "https://rpc-mumbai.maticvigil.com/",
      entrypoint: EntryPoint.v06,
    ),
    Network.baseTestent: Chain(
      chainId: 84531,
      explorer: "https://sepolia.basescan.org",
      jsonRpcUrl: "https://api-sepolia.basescan.org/api",
      entrypoint: EntryPoint.v06,
    ),
    Network.localhost: Chain(
      chainId: 1337,
      explorer: "http://localhost:8545",
      jsonRpcUrl: "http://localhost:8545",
      bundlerUrl: "http://localhost:3000/rpc",
      entrypoint: EntryPoint.v06,
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
  static EthereumAddress entrypointv07 =
      EthereumAddress.fromHex("0x0000000071727De22E5E9d8BAf0edAc6f37da032");
  static EthereumAddress zeroAddress =
      EthereumAddress.fromHex("0x0000000000000000000000000000000000000000");

  Constants._();
}

enum EntryPoint {
  v06(0.6, "0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789"),
  v07(0.7, "0x0000000071727De22E5E9d8BAf0edAc6f37da032");

  final double version;
  final String hex;

  const EntryPoint(this.version, this.hex);

  EthereumAddress get address => EthereumAddress.fromHex(hex);
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
  baseTestent,

  // localhost
  localhost
}
