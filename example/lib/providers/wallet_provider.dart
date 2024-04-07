import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:variance_dart/variance_dart.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart' as w3d;
import 'package:web3dart/crypto.dart' as w3d;

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
      EthereumAddress.fromHex("0x218F6Bbc32Ef28F547A67c70AbCF8c2ea3b468BA");

  WalletProvider()
      : _chain = Chain(
            chainId: 11155111,
            explorer: "https://sepolia.etherscan.io/",
            entrypoint: EntryPointAddress.v07)
          ..accountFactory = EthereumAddress.fromHex(
              "0xECA49857B32A12403F5a3A64ad291861EF4B63cb") // v07 p256 factory address
          ..jsonRpcUrl = "https://rpc.ankr.com/eth_sepolia"
          ..bundlerUrl =
              "https://api.pimlico.io/v2/11155111/rpc?apikey=YOUR_API_KEY"
          ..paymasterUrl =
              "https://api.pimlico.io/v2/11155111/rpc?apikey=YOUR_API_KEY";

  // "0x402A266e92993EbF04a5B3fd6F0e2b21bFC83070" v06 p256 factory address
  Future<void> registerWithPassKey(String name,
      {bool? requiresUserVerification}) async {
    final pkpSigner =
        PassKeySigner("webauthn.io", "webauthn", "https://webauthn.io");
    final hwdSigner = HardwareSigner.withTag(name);

    final salt = Uint256.fromHex(
        hexlify(w3d.keccak256(Uint8List.fromList(utf8.encode(name)))));

    try {
      // uses passkeys on android, secure enclave on iOS
      if (Platform.isAndroid) {
        final SmartWalletFactory walletFactory =
            SmartWalletFactory(_chain, pkpSigner);
        final keypair = await pkpSigner.register(name, name);
        _wallet =
            await walletFactory.createP256Account<PassKeyPair>(keypair, salt);
      } else if (Platform.isIOS) {
        final SmartWalletFactory walletFactory =
            SmartWalletFactory(_chain, hwdSigner);
        final keypair = await hwdSigner.generateKeyPair();
        _wallet = await walletFactory.createP256Account<P256Credential>(
            keypair, salt);
      }

      log("wallet created ${_wallet?.address.hex} ");
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      log("something happened: $e");
    }
  }

  Future<void> createEOAWallet() async {
    _chain.accountFactory = Constants.simpleAccountFactoryAddressv06;

    final signer = EOAWallet.createWallet();
    log("signer: ${signer.getAddress()}");

    final SmartWalletFactory walletFactory = SmartWalletFactory(_chain, signer);
    final salt = Uint256.fromHex(hexlify(w3d
        .keccak256(EthereumAddress.fromHex(signer.getAddress()).addressBytes)));

    try {
      _wallet = await walletFactory.createSimpleAccount(salt);
      log("wallet created ${_wallet?.address.hex} ");
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      log("something happened: $e");
    }
  }

  Future<void> createPrivateKeyWallet() async {
    _chain.accountFactory = Constants.simpleAccountFactoryAddressv06;

    final signer = PrivateKeySigner.createRandom("123456");
    log("signer: ${signer.getAddress()}");

    final SmartWalletFactory walletFactory = SmartWalletFactory(_chain, signer);

    final salt = Uint256.fromHex(hexlify(w3d
        .keccak256(EthereumAddress.fromHex(signer.getAddress()).addressBytes)));

    log("salt: ${salt.toHex()}");

    try {
      _wallet = await walletFactory.createSimpleAccount(salt);
      log("wallet created ${_wallet?.address.hex} ");
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

    final salt = Uint256.fromHex(hexlify(w3d
        .keccak256(EthereumAddress.fromHex(signer.getAddress()).addressBytes)));

    log("salt: ${salt.toHex()}");

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
