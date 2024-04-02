import 'dart:convert';
import 'dart:developer';
import 'dart:io';
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

  Future<void> registerWithHDWallet() async {
    final signer = EOAWallet.createWallet();
    log("mnemonic: ${signer.exportMnemonic()}");

    final SmartWalletFactory walletFactory = SmartWalletFactory(_chain, signer);

    final salt = Uint256.fromHex(hexlify(w3d.keccak256(
        Uint8List.fromList(utf8.encode(signer.getAddress().substring(2))))));

    _chain.accountFactory = Constants.safeProxyFactoryAddress;
    final safe = await walletFactory.createSafeAccount(salt);
    log("safe created ${safe.address.hex} ");

    try {
      _chain.accountFactory = Constants.simpleAccountFactoryAddress;
      _wallet = await walletFactory.createSimpleAccount(salt);
      log("wallet created ${_wallet?.address.hex} ");
    } catch (e) {
      log("something happened: $e");
    }
  }

  Future<void> mintNFt() async {}

  Future<void> sendTransaction(String recipient, String amount) async {
    if (_wallet != null) {
      final etherAmount =
          w3d.EtherAmount.fromBase10String(w3d.EtherUnit.ether, amount);
      await _wallet!.send(EthereumAddress.fromHex(recipient), etherAmount);
    } else {
      log("No wallet available to send transaction");
    }
  }
}
