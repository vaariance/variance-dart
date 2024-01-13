// ignore_for_file: public_member_api_docs

import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:variance_dart/utils.dart';
import 'package:variance_dart/variance.dart';
import 'package:web3dart/web3dart.dart';

const String rpcUrl = 'http://localhost:8545';
const String bundlerUrl = 'http://localhost:3000/rpc';

Future<void> main() async {
  final Uint256 salt = Uint256.zero;

  // configure your chain
  final Chain chain = Chain(
      ethRpcUrl: rpcUrl,
      bundlerUrl: bundlerUrl,
      entrypoint: Constants.entrypoint,
      accountFactory: Constants.accountFactory,
      chainId: 1337,
      explorer: "");

  // create smart wallet signer based of seed phrase
  final HDWalletSigner hd = HDWalletSigner.createWallet();
  print("mnemonic: ${hd.exportMnemonic()}");

  // create a smart wallet signer based on passkeys
  // this operation requires biometrics verification from the user
  final PassKeyPair pkp =
      await PassKeySigner("myapp.xyz", "myapp", "https://myapp.xyz")
          .register("<user name>", true);
  print("pkp: ${pkp.toJson()}");

  // save a signer credential to device
  await hd
      .withSecureStorage(FlutterSecureStorage())
      .saveCredential(CredentialType.hdwallet);

  // load a credential from the device
  final ss = SecureStorageMiddleware(secureStorage: FlutterSecureStorage());
  final hdInstance =
      await HDWalletSigner.loadFromSecureStorage(storageMiddleware: ss);
  print("pkp: ${hdInstance?.exportMnemonic()}");

  // NOTE: interactions with securestorage can be authenticated when using `SecureStorageMiddleware`
  //
  // final ss = SecureStorageMiddleware(secureStorage: FlutterSecureStorage(), authMiddleware: AuthenticationMiddleware());
  // then used with `SecureStorageMiddleware` in the following way
  //
  // ss.save("key", "value", options: SSAuthOperationOptions(requiresAuth: true, authReason: "reason"))
  // ss.read("key") // default options are used i.e requiresAuth: false
  // ss.delete("key", options: SSAuthOperationOptions(requiresAuth: false)) // explicitly reject authentication
  //;

  // create a smart wallet client
  final walletClient = SmartWallet(
    chain: chain,
    signer: hd,
    bundler: BundlerProvider(chain, RPCProvider(chain.bundlerUrl!)),
  );

  // create a simple account based on hd
  final SmartWallet simpleSmartAccount =
      await walletClient.createSimpleAccount(salt);
  print("simple account address: ${simpleSmartAccount.address}");

  // create a simple account based on pkp
  final SmartWallet simplePkpAccount =
      await walletClient.createSimplePasskeyAccount(pkp, salt);
  print("simple pkp account address: ${simplePkpAccount.address}");

  // retrieve the balance of a smart wallet
  final EtherAmount balance = await simpleSmartAccount.balance;
  print("account balance: ${balance.getInWei}");

  // retrive the account nonce
  final Uint256 nonce = await simpleSmartAccount.nonce;
  print("account nonce: ${nonce.toInt()}");

  // check if a smart wallet has been deployed
  final bool deployed = await simpleSmartAccount.deployed;
  print("account deployed: $deployed");

  // get the init code of the smart wallet
  final String initCode = simpleSmartAccount.initCode;
  print("account init code: $initCode");

  // perform a simple transaction (send ether to another account)
  // account must be prefunded with native token. paymaster is not yet implemented
  await simpleSmartAccount.send(
    EthereumAddress.fromHex(
        "0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789"), // receive address
    getConversion("0.7142"), // 0.7142 ether
  );
}

EtherAmount getConversion(String amount) {
  final amtToDb = double.parse(amount);
  return EtherAmount.fromBigInt(
      EtherUnit.wei, BigInt.from(amtToDb * pow(10, 18)));
}
