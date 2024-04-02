import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:variance_dart/variance.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart' as w3d;
import 'package:web3dart/crypto.dart' as w3d;

class WalletProvider extends ChangeNotifier {
  final Chain _chain;

  SmartWallet? _wallet;
  SmartWallet? get wallet => _wallet;

  String _errorMessage = "";
  String get errorMessage => _errorMessage;

  WalletProvider()
      : _chain = Chains.getChain(Network.baseTestnet)
          ..accountFactory = EthereumAddress.fromHex(
              "0x402A266e92993EbF04a5B3fd6F0e2b21bFC83070")
          ..bundlerUrl =
              "https://base-sepolia.g.alchemy.com/v2/RWbMhXe00ZY-SjGQF72kyCVQJ_nQopba"
          ..jsonRpcUrl =
              "https://base-sepolia.g.alchemy.com/v2/RWbMhXe00ZY-SjGQF72kyCVQJ_nQopba";

  Future<void> registerWithPassKey(String name,
      {bool? requiresUserVerification}) async {
    final pkpSigner =
        PassKeySigner("webauthn.io", "webauthn", "https://webauthn.io");
    final hwdSigner = HardwareSigner.withTag(name);

    final SmartWalletFactory walletFactory =
        SmartWalletFactory(_chain, pkpSigner);

    final salt = Uint256.fromHex(
        hexlify(w3d.keccak256(Uint8List.fromList(utf8.encode(name)))));

    try {
      // uses passkeys on android, secure enclave on iOS
      if (Platform.isAndroid) {
        final keypair = await pkpSigner.register(name, name);
        _wallet =
            await walletFactory.createP256Account<PassKeyPair>(keypair, salt);
      } else if (Platform.isIOS) {
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

  Future<void> mintNFt() async {}

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
