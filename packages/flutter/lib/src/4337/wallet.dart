library pks_4337_sdk;

import 'dart:typed_data';

import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/4337/chains.dart';
import 'package:pks_4337_sdk/src/4337/modules/contract.dart';
import 'package:pks_4337_sdk/src/4337/modules/contract_abis.dart';
import 'package:pks_4337_sdk/src/4337/modules/nft.dart';
import 'package:pks_4337_sdk/src/4337/modules/token.dart';
import 'package:pks_4337_sdk/src/4337/modules/transfers.dart';
import 'package:pks_4337_sdk/src/abi/accountFactory.g.dart';
import 'package:pks_4337_sdk/src/abi/entrypoint.g.dart';
import "package:web3dart/web3dart.dart";

class Wallet extends Signer {
  /// [PROVIDERS]
  final BaseProvider _baseProvider;
  final BundlerProvider _walletProvider;
  final IChain _walletChain;

  /// [MODULES]
  late final NFT nft;
  late final Tokens tokens;
  late final Transfers transfers;
  late final Contract contract;

  /// [GETTERS]
  BaseProvider get baseProvider => _baseProvider;
  BundlerProvider get walletProvider => _walletProvider;
  IChain get walletChain => _walletChain;

  /// [WALLET_ADDRESS]
  EthereumAddress _walletAddress;
  Address get address => Address.fromEthAddress(_walletAddress);
  String toHex() => _walletAddress.hexEip55;

  /// [Entrypoint] is not initialized
  /// to initialize with entrypoint, you have to call [Wallet.init] instead
  ///
  /// Creates an instance of [Wallet]
  Wallet(
      {required IChain chain,
      super.hdkey,
      super.passkey,
      super.signer,
      EthereumAddress? address})
      : _walletChain = chain.validate(),
        _walletProvider = BundlerProvider(chain),
        _baseProvider = BaseProvider(chain.rpcUrl!),
        _walletAddress = address ?? Chains.zeroAddress {
    _initializeModules(_baseProvider);
  }

  /// initializes the [Wallet] modules
  /// - nft module
  /// - token module
  /// - contract module
  /// - transfers module
  _initializeModules(BaseProvider provider) {
    nft = NFT(provider.rpcUrl);
    tokens = Tokens(provider);
    transfers = Transfers(provider);
    contract = Contract(provider);
  }

  /// creates a [Wallet] instance, additionally initializes the [Entrypoint] contract
  /// use [Wallet.init] directly when you:
  /// - need to interact with the entrypoint.
  /// - want to [wait] for user Operation Events.
  /// - recovering account.
  static Wallet init(IChain chain,
      {HDkeysInterface? hdkey,
      PasskeysInterface? passkey,
      SignerType signer = SignerType.hdkeys,
      EthereumAddress? address}) {
    final instance = Wallet(
        chain: chain,
        hdkey: hdkey,
        passkey: passkey,
        signer: signer,
        address: address);
    final custom = Web3Client.custom(instance.baseProvider);
    instance._walletProvider.initializeWithEntrypoint(
        Entrypoint(
          address: chain.entrypoint,
          client: custom,
        ),
        custom);
    return instance;
  }

  Future<EtherAmount> get balance => contract.getBalance(_walletAddress);

  Future<bool> get deployed => contract.deployed(_walletAddress);

  Future<Uint256> get nonce => _nonce();

  Future<Uint256> _nonce() async {
    return contract.call<BigInt>(_walletAddress, ContractAbis.get('getNonce'),
        "getNonce", []).then((value) => Uint256(value[0]));
  }

  /// [create] -> creates a new wallet address.
  /// uses counterfactual deployment, so wallet may not actually be deployed
  /// given the same exact inputs, the same exact address will be generated.
  /// use [deployed] to check if wallet is deployed.
  /// an `initCode` will be attached on the first transaction.
  create(Uint256 salt, {int? index, String? accountId}) async {
    require(defaultSigner == SignerType.hdkeys && hdkey != null,
        "Create: HD Key instance is required!");
    EthereumAddress owner = EthereumAddress.fromHex(
        await hdkey!.getAddress(index ?? 0, id: accountId));
    FactoryInterface factory = AccountFactory(
        address: Chains.accountFactory,
        client: Web3Client.custom(_baseProvider),
        chainId: _walletChain.chainId) as FactoryInterface;
    factory
        .getAddress(owner, salt.value)
        .then((value) => {_walletAddress = value});
  }

  /// [createPasskeyAccount] -> creates a new Passkey wallet address.
  /// uses counterfactual deployment, so wallet may not actually be deployed
  /// given the same exact inputs, the same exact address will be generated.
  /// use [deployed] to check if wallet is deployed.
  /// an `initCode` will be attached on the first transaction.
  createPasskeyAccount(
      Uint8List credentialHex, Uint256 x, Uint256 y, Uint256 salt) async {
    require(defaultSigner == SignerType.passkeys && passkey != null,
        "Create P256: PassKey instance is required!");
    FactoryInterface factory = AccountFactory(
        address: Chains.accountFactory,
        client: Web3Client.custom(_baseProvider),
        chainId: _walletChain.chainId) as FactoryInterface;
    factory
        .getPasskeyAccountAddress(credentialHex, x.value, y.value, salt.value)
        .then((value) => {_walletAddress = value});
  }

  // UserOperation buildUserOperation() {}
  Future signTransaction() async {}
  Future sendTransaction() async {}
  Future signAndSendTransaction() async {}
  Future sendBatchedTransaction() async {}
  Future transferToken(EthereumAddress tokenAddress,
      EthereumAddress recipientAddress, BigInt amount) async {}

  Future transferNFT(EthereumAddress nftContractAddress,
      EthereumAddress recipientAddress, num tokenId) async {}

  Future approveNFT(
    EthereumAddress nftContractAddress,
    EthereumAddress spender,
    BigInt tokenId,
  ) async {}

  Future approveToken(
    EthereumAddress tokenAddress,
    EthereumAddress spender,
    BigInt amount,
  ) async {}

  Future send() async {}
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
// Future<UserOperationResponse?> sendTransaction({
//     required EthereumAddress to,
//     required Uint256 value,
//     required Uint8List payload,
//     BundlerProvider? bundlerProvider,
//   }) async {
//     if (!(await _checkDeployment())) {}
//     final nonce = await getNonce();
//     UserOperation userOp = UserOperation(
//       toHex(),
//       nonce.value,
//       '',
//       '$payload',
//       BigInt.tryParse('$value') ?? BigInt.from(0),
//       BigInt.from(0),
//       BigInt.from(0),
//       BigInt.from(0),
//       BigInt.from(0),
//       '',
//       '',
//     );
//     final signedOps = await sign(userOp);
//     final response = await bundlerProvider?.sendUserOperation(
//         signedOps, Chains.entrypoint as String);
//     if (response?.userOpHash == null) {
//       throw Exception('Error sending transaction');
//     }

//     return response;
//   }