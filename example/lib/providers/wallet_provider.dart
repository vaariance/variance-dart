import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:variance_dart/variance_dart.dart';
import 'package:web3dart/web3dart.dart';

class WalletProvider extends ChangeNotifier {
  final Chain _chain;

  SmartWallet? _wallet;
  SmartWallet? get wallet => _wallet;

  String _errorMessage = "";
  String get errorMessage => _errorMessage;

  final EthereumAddress nft =
      EthereumAddress.fromHex("0x3661b40C520a273214d281bd84730BA68604d874");
  final EthereumAddress erc20 =
      EthereumAddress.fromHex("0x69583ED4AA579fdc83FB6CCF13A5Ffd9B39F62aF");
  final EthereumAddress deployer =
      EthereumAddress.fromHex("0xf5bb7f874d8e3f41821175c0aa9910d30d10e193");
  final EthereumAddress sharedSigner =
      EthereumAddress.fromHex("0x94a4F6affBd8975951142c3999aEAB7ecee555c2");
  final EthereumAddress p256Verifier =
      EthereumAddress.fromHex("0xc2b78104907F722DABAc4C69f826a522B2754De4");

  final salt = Uint256.zero;
  static const rpc =
      "https://api.pimlico.io/v2/123/rpc?apikey=${"PIMLICO_API_KEY"}";

  WalletProvider()
      : _chain = Chain(
            bundlerUrl: rpc,
            // paymasterUrl: rpc, // for fuse network, not really working.
            testnet: true,
            chainId: 123,
            jsonRpcUrl: "https://rpc.fusespark.io",
            accountFactory: Constants.safeProxyFactoryAddress,
            explorer: "https://explorer.fusespark.io/",
            entrypoint: EntryPointAddress.v07);

  Future<void> registerWithPassKey(String name,
      {bool? requiresUserVerification}) async {
    final options = PassKeysOptions(
      name: "variance",
      namespace: "variance.space",
      sharedWebauthnSigner: sharedSigner,
    );
    final pkpSigner = PassKeySigner(options: options);

    try {
      final SmartWalletFactory walletFactory =
          SmartWalletFactory(_chain, pkpSigner);
      final keypair = await pkpSigner.register(
          "${DateTime.timestamp().millisecondsSinceEpoch}@variance.space",
          name);
      _wallet = await walletFactory.createSafeAccountWithPasskey(
          keypair, salt, options.sharedWebauthnSigner, p256Verifier);
      overrideGas();
      log("wallet created ${_wallet?.address.hex} ");
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      log("something happened: $e");
      rethrow;
    }
  }

  Future<void> createEOAWallet() async {
    _chain.accountFactory = Constants.lightAccountFactoryAddressv07;

    final signer = EOAWallet.createWallet(
        WordLength.word_12, const SignatureOptions(prefix: [0]));
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
    _chain.accountFactory = Constants.lightAccountFactoryAddressv07;

    final signer = PrivateKeySigner.createRandom(
        "password", const SignatureOptions(prefix: [0]));
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

  Future<void> createSafeWallet() async {
    final signer = EOAWallet.createWallet();
    final SmartWalletFactory walletFactory = SmartWalletFactory(_chain, signer);

    try {
      _wallet = await walletFactory.createSafeAccount(salt);
      overrideGas();
      log("wallet created ${_wallet?.address.hex} ");
    } catch (e) {
      log("something happened: $e");
    }
  }

  Future<void> mintNFt() async {
    // simple tx
    final tx1 = await _wallet?.sendTransaction(
        nft,
        Contract.encodeFunctionCall("safeMint", nft,
            ContractAbis.get("ERC721_SafeMint"), [_wallet?.address]));
    await tx1?.wait();

    // batch tx
    final tx2 = await _wallet?.sendBatchedTransaction([
      erc20,
      erc20
    ], [
      Contract.encodeFunctionCall(
          "mint", erc20, ContractAbis.get("ERC20_Mint"), [
        _wallet?.address,
        EtherAmount.fromInt(EtherUnit.ether, 20).getInWei
      ]),
      Contract.encodeERC20TransferCall(
          erc20, deployer, EtherAmount.fromInt(EtherUnit.ether, 20))
    ]);

    await tx2?.wait();
  }

  Future<void> sendTransaction(String recipient, String amount) async {
    final etherAmount = EtherAmount.fromBigInt(
        EtherUnit.wei, BigInt.from(double.parse(amount) * math.pow(10, 18)));

    final response = await _wallet?.send(deployer, etherAmount);
    final receipt = await response?.wait();

    log("Transaction receipt Hash: ${receipt?.userOpHash}");
  }

  overrideGas() {
    //@dev use only when using contract verifier,
    // do not use this function with precompiles.
    // for the safe deployment transaction do not use the multiplier
    // multiply verification gas until it exceeds 400k gas
    _wallet?.gasSettings = GasSettings(
        verificationGasMultiplierPercentage:
            650, //7.5x higher than base - about 410k. adjust if needed
        userDefinedMaxFeePerGas: BigInt.from(24500000000),
        userDefinedMaxPriorityFeePerGas: BigInt.from(12300000000));
  }
}
