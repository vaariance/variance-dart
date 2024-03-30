import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:variance_dart/variance.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart' as w3d;
import 'package:web3dart/crypto.dart' as w3d;

class WalletProvider extends ChangeNotifier {
  final Chain _chain;

  PassKeyPair? _keyPair;

  late SmartWallet _wallet;

  SmartWallet get wallet => _wallet;

  WalletProvider()
      : _chain = Chains.getChain(Network.baseTestent)
          ..bundlerUrl =
              "https://base-sepolia.g.alchemy.com/v2/RWbMhXe00ZY-SjGQF72kyCVQJ_nQopba"
          ..jsonRpcUrl =
              "https://base-sepolia.g.alchemy.com/v2/RWbMhXe00ZY-SjGQF72kyCVQJ_nQopba";

  Future registerWithPassKey(String name,
      {bool? requiresUserVerification}) async {
    final signer =
        PassKeySigner("webauthn.io", "webauthn", "https://webauthn.io");
    final SmartWalletFactory walletFactory = SmartWalletFactory(_chain, signer);

    _keyPair = await signer.register(name);

    try {
      final salt = Uint256.fromHex(
          hexlify(w3d.keccak256(Uint8List.fromList(utf8.encode(name)))));
      _wallet =
          await walletFactory.createP256Account<PassKeyPair>(_keyPair!, salt);
      log("wallet created ${_wallet.address.hex} ");
    } catch (e) {
      log("something happened: $e");
    }
  }

  Future registerWithHDWallet() async {
    final signer = EOAWallet.createWallet();
    log("mnemonic: ${signer.exportMnemonic()}");
    final SmartWalletFactory walletFactory = SmartWalletFactory(_chain, signer);

    try {
      final salt = Uint256.fromHex(hexlify(w3d.keccak256(
          Uint8List.fromList(utf8.encode(signer.getAddress().substring(2))))));
      _wallet = await walletFactory.createSimpleAccount(salt);
      log("wallet created ${_wallet.address.hex} ");
    } catch (e) {
      log("something happened: $e");
    }
  }

  Future<void> sendTransaction(String recipient, String amount) async {
    final etherAmount =
        w3d.EtherAmount.fromBase10String(w3d.EtherUnit.ether, amount);
    await wallet.send(EthereumAddress.fromHex(recipient), etherAmount);
  }
}
