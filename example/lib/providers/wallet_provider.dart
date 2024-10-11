import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:variance_dart/variance_dart.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart' as w3d;

class WalletProvider extends ChangeNotifier {
  final Chain _chain;

  SmartWallet? _wallet;
  SmartWallet? get wallet => _wallet;

  String _errorMessage = "";
  String get errorMessage => _errorMessage;

  final EthereumAddress nft =
      EthereumAddress.fromHex("0x4B509a7e891Dc8fd45491811d67a8B9e7ef547B9");
  final EthereumAddress erc20 =
      EthereumAddress.fromHex("0xAEaF19097D8a8da728438D6B57edd9Bc5DAc4795");
  final EthereumAddress deployer =
      EthereumAddress.fromHex("0xf5bb7f874d8e3f41821175c0aa9910d30d10e193");

  final salt = Uint256.zero;
  static const rpc =
      "https://api.pimlico.io/v2/84532/rpc?apikey=pim_NuuL4a9tBdyfoogF5LtP5A";

  WalletProvider()
      : _chain = Chains.getChain(Network.baseTestnet)
          ..accountFactory = Constants.lightAccountFactoryAddressv07
          ..bundlerUrl = rpc
          ..paymasterUrl = rpc;

  Future<void> registerWithPassKey(String name,
      {bool? requiresUserVerification}) async {
    _chain.accountFactory = Constants.safeProxyFactoryAddress;

    final options = PassKeysOptions(
        name: "variance",
        namespace: "variance.space",
        origin: "https://variance.space",
        userVerification: "required",
        requireResidentKey: true,
        sharedWebauthnSigner: EthereumAddress.fromHex(
            "0xfD90FAd33ee8b58f32c00aceEad1358e4AFC23f9"));
    final pkpSigner = PassKeySigner(options: options);

    try {
      final SmartWalletFactory walletFactory =
          SmartWalletFactory(_chain, pkpSigner);
      final keypair = await pkpSigner.register(
          "${DateTime.timestamp().millisecondsSinceEpoch}@variance.space",
          name);
      _wallet = await walletFactory.createSafeAccountWithPasskey(
          keypair, salt, options.sharedWebauthnSigner);

      log("wallet created ${_wallet?.address.hex} ");
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      log("something happened: $e");
      rethrow;
    }
  }

  Future<void> createEOAWallet() async {
    final signer = EOAWallet.createWallet(
        WordLength.word_12, const SignatureOptions(prefix: [0]));
    log("signer: ${signer.getAddress()}");

    final SmartWalletFactory walletFactory = SmartWalletFactory(_chain, signer);

    try {
      _wallet = await walletFactory.createAlchemyLightAccount(salt);
      log("wallet created ${_wallet?.address.hex} ");
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      log("something happened: $e");
    }
  }

  Future<void> createPrivateKeyWallet() async {
    final random = math.Random.secure();
    final privateKey = EthPrivateKey.createRandom(random);

    final signer = PrivateKeySigner.create(privateKey, "123456", random,
        options: const SignatureOptions(prefix: [0]));
    log("signer: ${signer.getAddress()}");
    log("pk: ${hexlify(privateKey.privateKey)}");

    final SmartWalletFactory walletFactory = SmartWalletFactory(_chain, signer);

    try {
      _wallet = await walletFactory.createAlchemyLightAccount(salt);
      log("pk wallet created ${_wallet?.address.hex} ");
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      log("something happened: $e");
    }
  }

  Future<void> createSafeWallet() async {
    _chain.accountFactory = Constants.safeProxyFactoryAddress;

    final signer = EOAWallet.createWallet();
    log("signer: ${signer.getAddress()}");

    final SmartWalletFactory walletFactory = SmartWalletFactory(_chain, signer);

    try {
      _wallet = await walletFactory.createSafeAccount(salt);
      log("safe created ${_wallet?.address.hex} ");
    } catch (e) {
      log("something happened: $e");
    }
  }

  Future<void> mintNFt() async {
    // pimlico requires us to get the gasfees from their bundler.
    // that cannot be built into the sdk so we modify the internal fees manually
    if (_chain.entrypoint.version == 0.7) {
      _wallet?.gasSettings = GasSettings(
          gasMultiplierPercentage: 5,
          userDefinedMaxFeePerGas: BigInt.parse("0x524e1909"),
          userDefinedMaxPriorityFeePerGas: BigInt.parse("0x52412100"));
    }
    // mints nft
    log(DateTime.timestamp().toString());
    final tx1 = await _wallet?.sendTransaction(
        nft,
        Contract.encodeFunctionCall("safeMint", nft,
            ContractAbis.get("ERC721_SafeMint"), [_wallet?.address]));
    await tx1?.wait();

    await sendBatchedTransaction();
  }

  Future<void> sendBatchedTransaction() async {
    final tx = await _wallet?.sendBatchedTransaction([
      erc20,
      erc20
    ], [
      Contract.encodeFunctionCall(
          "mint", erc20, ContractAbis.get("ERC20_Mint"), [
        _wallet?.address,
        w3d.EtherAmount.fromInt(w3d.EtherUnit.ether, 20).getInWei
      ]),
      Contract.encodeERC20TransferCall(
          erc20, deployer, w3d.EtherAmount.fromInt(w3d.EtherUnit.ether, 20))
    ]);

    await tx?.wait();
  }

  Future<void> sendTransaction(String recipient, String amount) async {
    if (_wallet != null) {
      final etherAmount = w3d.EtherAmount.fromBigInt(w3d.EtherUnit.wei,
          BigInt.from(double.parse(amount) * math.pow(10, 18)));

      final response =
          await _wallet?.send(EthereumAddress.fromHex(recipient), etherAmount);
      final receipt = await response?.wait();

      log("Transaction receipt Hash: ${receipt?.userOpHash}");
    } else {
      log("No wallet available to send transaction");
    }
  }
}
