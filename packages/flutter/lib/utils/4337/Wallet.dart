import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:passkeysafe/utils/4337/abi/entrypoint.g.dart';
import 'package:passkeysafe/utils/4337/providers.dart';
import 'package:passkeysafe/utils/4337/signer.dart';
import 'package:passkeysafe/utils/4337/userop.dart';
import 'package:passkeysafe/utils/key_manager.dart';
import 'package:passkeysafe/utils/passkeys.dart';
import 'package:web3dart/json_rpc.dart';
import "package:web3dart/web3dart.dart";

import './chains.dart';

class Wallet extends Signer {
  final Web3Client walletClient;
  final BundlerProvider walletProvider;
  final IChain walletChain;

  Wallet({required IChain chain, super.hdkey, super.passkey, super.signer})
      : walletChain = chain.validate(),
        walletProvider = BundlerProvider(chain.chainId, chain.bundlerUrl!),
        walletClient = Web3Client.custom(JsonRPC(chain.rpcUrl!, http.Client()));

  static Wallet init(IChain chain,
      {HDkeysInterface? hdkey,
      PasskeysInterface? passkey,
      SignerType signer = SignerType.hdkeys}) {
    final instance =
        Wallet(chain: chain, hdkey: hdkey, passkey: passkey, signer: signer);
    return instance;
  }

  Future<FilterEvent?> wait(int milisecs) async {
    Entrypoint entrypoint = Entrypoint(
      address: EthereumAddress.fromHex(walletChain.entrypoint!),
      client: walletClient,
    );
    final block = await walletClient.getBlockNumber();
    final end = DateTime.now().millisecondsSinceEpoch + milisecs;
    while (DateTime.now().millisecondsSinceEpoch < end) {
      final userOperationEvent = entrypoint.self.event('UserOperationEvent');
      final filterEvent = await walletClient
          .events(
            FilterOptions.events(
              contract: entrypoint.self,
              event: userOperationEvent,
              fromBlock: BlockNum.exact(block - 100),
            ),
          )
          .take(1)
          .first;
      if (filterEvent.transactionHash != null) {
        return filterEvent;
      }
      await Future.delayed(Duration(milliseconds: milisecs));
    }
    return null;
  }

  Future getBalance() async {
    final balance = await walletClient
        .getBalance(EthereumAddress.fromHex(walletChain.entrypoint!));
    return balance;
  }

  Future getNonce() async {
    final nonce = await walletClient
        .getTransactionCount(EthereumAddress.fromHex(walletChain.entrypoint!));
    return nonce;
  }

  Future getGasPrice() async {
    final gasPrice = await walletClient.getGasPrice();
    return gasPrice;
  }

  Future generate() async {
    /// creates a new wallet via counter factual deployment
  }

  Future isDeployed() async {
    /// checks if a smart wallet is deployed
  }

  Future sendTransaction() async {
    /// sends a transaction via a smart wallet
  }

  Future sendBatchedTransaction() async {
    /// sends a batched transaction via a smart wallet
  }

  Future signTransaction() async {
    /// signs a transaction via a smart wallet
  }

  Future transfer() async {
    /// transfers erc20/721/1155 tokens via a smart wallet
  }

  Future send() async {
    /// sends ether via a smart wallet
  }

  Future getAddress() async {
    /// gets the address of a smart wallet
  }





  Future userOptester() async {
    final uop = UserOperation(
      "0x3AcF7270a4e8D1d1b0656aA76E50C28a40446e77",
      BigInt.from(2),
      '0x',
      '0xb61d27f60000000000000000000000003acf7270a4e8d1d1b0656aa76e50c28a40446e77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000004b0d691fe00000000000000000000000000000000000000000000000000000000',
      BigInt.from(55000),
      BigInt.from(80000),
      BigInt.from(51000),
      BigInt.zero,
      BigInt.zero,
      '0x065f98b3a6250d7a2ba16af1d9cd70e7399dfdd43a59b066fad919c0b0091d8a0ae13b9ee0dc11576f89fb86becac6febf1ea859cb5dad5f3aac3d024eb77f681c',
      '0x',
    ).toMap();

    final etp = await walletProvider.getUserOpReceipt(
        "0x968330a7d22692ee1214512ee474de65ff00d246440978de87e5740d09d2d354");
    log("etp: ${etp.toString()}");
    // walletProvider.sendUserOperation(et, entryPoint)
  }
}
