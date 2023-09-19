library passkeysafe;

import 'dart:developer';

import 'package:passkeysafe/src/utils/4337/abi/entrypoint.g.dart';
import 'package:passkeysafe/src/utils/4337/abi/simpleAccountFactory.g.dart';
import 'package:passkeysafe/src/utils/4337/chains.dart';
import 'package:passkeysafe/src/utils/4337/providers.dart';
import 'package:passkeysafe/src/utils/4337/signer.dart';
import 'package:passkeysafe/src/utils/4337/userop.dart';
import 'package:passkeysafe/src/utils/common.dart';
import 'package:passkeysafe/src/utils/interfaces.dart';
import "package:web3dart/web3dart.dart";
import 'package:http/http.dart' as http;
import 'package:web3dart/json_rpc.dart';

class Wallet extends Signer {
  final Web3Client walletClient;
  final BundlerProvider walletProvider;
  final IChain walletChain;

  late final Entrypoint entrypoint;
  late final bool _deployed;

  EthereumAddress _walletAddress;
  EthereumAddress get address => _walletAddress;
  String toHex() => _walletAddress.hexEip55;

  Wallet(
      {required IChain chain,
      super.hdkey,
      super.passkey,
      super.signer,
      EthereumAddress? address})
      : walletChain = chain.validate(),
        walletProvider = BundlerProvider(chain.chainId, chain.bundlerUrl!),
        walletClient = Web3Client.custom(JsonRPC(chain.rpcUrl!, http.Client())),
        _walletAddress = address ?? Chains.zeroAddress;

  static Wallet init(IChain chain,
      {HDkeysInterface? hdkey,
      PasskeysInterface? passkey,
      SignerType signer = SignerType.hdkeys}) {
    final instance =
        Wallet(chain: chain, hdkey: hdkey, passkey: passkey, signer: signer);
    instance.entrypoint = Entrypoint(
      address: chain.entrypoint,
      client: instance.walletClient,
    );
    return instance;
  }

  Future<EtherAmount> getBalance() async =>
      await walletClient.getBalance(_walletAddress);

  Future<Uint256> getNonce({BigInt? key}) async =>
      Uint256(await entrypoint.getNonce(_walletAddress, key ?? BigInt.zero));

  Future<EtherAmount> getGasPrice() async => await walletClient.getGasPrice();

  Future<bool> deployed() async =>
      (await walletClient.getCode(_walletAddress)).isNotEmpty;

  _checkDeploymet() async {
    bool isDeployed = await deployed();
    isDeployed ? _deployed = true : null;
  }

  Future<EthereumAddress> _create(AccountFactoryInterface factory,
          EthereumAddress owner, Uint256 salt) async =>
      await factory.getAddress(owner, salt.value);

  Future<EthereumAddress> _createP256(
    AccountFactoryInterface factory,
    String credentialId,
    Uint256 pubKeyX,
    Uint256 pubKeyY,
    Uint256 salt,
  ) async =>
      await factory.getCredential(
          credentialId, pubKeyX.value, pubKeyY.value, salt.value);

  /// does not deploy an account
  /// only generates an address based on the provided inputs
  /// given the same exact inputs, the same exact address will be generated.
  /// [deployed] will be called before sending any transaction
  /// if contract is yet to be deployed, an initCode will be attached on the first transaction.
  Future create(Uint256 salt, {String? accountId}) async {
    AccountFactoryInterface factory = SimpleAccountFactory(
        address: Chains.simpleAccountFactory,
        client: walletClient,
        chainId: walletChain.chainId) as AccountFactoryInterface;
    require(defaultSigner == SignerType.hdkeys,
        "Create: you need to set HD Keys as your default Signer");
    require(hdkey != null, "Create: HD Key instance is required!");
    EthereumAddress owner =
        EthereumAddress.fromHex(await hdkey!.getAddress(0, id: accountId));
    _walletAddress = await _create(factory, owner, salt);
  }

  Future createP256(String credentialId, Uint256 pubKeyX, Uint256 pubKeyY,
      Uint256 salt) async {
    AccountFactoryInterface factory = SimpleAccountFactory(
        address: Chains.simpleAccountFactory,
        client: walletClient,
        chainId: walletChain.chainId) as AccountFactoryInterface;
    require(defaultSigner == SignerType.passkeys,
        "Create P256: you need to set PassKeys as your default Signer");
    require(passkey != null, "Create P256: PassKey instance is required!");
    _walletAddress =
        await _createP256(factory, credentialId, pubKeyX, pubKeyY, salt);
  }

  Future buildCustomUserOp() async {
    /// builds a custom user operation
  }

  Future sendUserOperation() async {
    /// sends a custom built user operation via a smart wallet
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

  Future<FilterEvent?> wait(int millisecond) async {
    final block = await walletClient.getBlockNumber();
    final end = DateTime.now().millisecondsSinceEpoch + millisecond;
    while (DateTime.now().millisecondsSinceEpoch < end) {
      final filterEvent = await walletClient
          .events(
            FilterOptions.events(
              contract: entrypoint.self,
              event: entrypoint.self.event('UserOperationEvent'),
              fromBlock: BlockNum.exact(block - 100),
            ),
          )
          .take(1)
          .first;
      if (filterEvent.transactionHash != null) {
        return filterEvent;
      }
      await Future.delayed(Duration(milliseconds: millisecond));
    }
    return null;
  }
}

  // Future userOptester() async {
  //   final uop = UserOperation(
  //     "0x3AcF7270a4e8D1d1b0656aA76E50C28a40446e77",
  //     BigInt.from(2),
  //     '0x',
  //     '0xb61d27f60000000000000000000000003acf7270a4e8d1d1b0656aa76e50c28a40446e77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000004b0d691fe00000000000000000000000000000000000000000000000000000000',
  //     BigInt.from(55000),
  //     BigInt.from(80000),
  //     BigInt.from(51000),
  //     BigInt.zero,
  //     BigInt.zero,
  //     '0x065f98b3a6250d7a2ba16af1d9cd70e7399dfdd43a59b066fad919c0b0091d8a0ae13b9ee0dc11576f89fb86becac6febf1ea859cb5dad5f3aac3d024eb77f681c',
  //     '0x',
  //   ).toMap();

  //   final etp = await walletProvider.getUserOpReceipt(
  //       "0x968330a7d22692ee1214512ee474de65ff00d246440978de87e5740d09d2d354");
  //   log("etp: ${etp.toString()}");
  //   // walletProvider.sendUserOperation(et, entryPoint)
  // }