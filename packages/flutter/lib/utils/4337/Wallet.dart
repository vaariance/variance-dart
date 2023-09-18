import 'package:http/http.dart' as http;
import 'package:passkeysafe/utils/4337/providers.dart';
import 'package:passkeysafe/utils/4337/signer.dart';
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

  
}
