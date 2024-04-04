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
      : _chain = Chains.getChain(Network.baseTestnet)
          ..accountFactory = EthereumAddress.fromHex(
              "0x402A266e92993EbF04a5B3fd6F0e2b21bFC83070")
          ..bundlerUrl = "https://api.pimlico.io/v2/84532/rpc?apikey="
          ..paymasterUrl = "https://paymaster.optimism.io/v1/84532/rpc";

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
    _chain.accountFactory = Constants.simpleAccountFactoryAddress;

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
    _chain.accountFactory = Constants.simpleAccountFactoryAddress;

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
    // mints nft
    final tx1 = await _wallet?.sendTransaction(
        nft,
        Contract.encodeFunctionCall("safeMint", nft,
            ContractAbis.get("ERC721_SafeMint"), [_wallet?.address]));
    await tx1?.wait();

    // mints erc20 tokens
    final tx2 = await _wallet?.sendTransaction(
        erc20,
        Contract.encodeFunctionCall(
            "mint", erc20, ContractAbis.get("ERC20_Mint"), [
          _wallet?.address,
          w3d.EtherAmount.fromInt(w3d.EtherUnit.ether, 20).getInWei
        ]));
    await tx2?.wait();

    // transfers the tokens
    final tx3 = await _wallet?.sendTransaction(
        erc20,
        Contract.encodeERC20TransferCall(
            erc20, deployer, w3d.EtherAmount.fromInt(w3d.EtherUnit.ether, 18)));
    await tx3?.wait();
    log("trying batched transaction");
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
