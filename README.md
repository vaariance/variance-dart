# Variance SDK

Variance is a Dart SDK designed to simplify interaction with Ethereum-based blockchains and enables flutter developers to implement account abstraction with minimal efforts. It provides functionalities such as encoding and decoding ABI data, handling Ethereum transactions, working with ERC20 and ERC721 tokens, and managing Ethereum smart accounts.

## Features

- **ABI Encoding/Decoding:** Easily encode and decode ABI data for Ethereum smart contract and Entrypoint interactions.
- **Transaction Handling:** Simplify the process of creating and sending UserOperations.
- **Token Operations:** Work with ERC20 and ERC721 tokens, including transfer and approval functionalities.
- **Secure Storage:** Securely store and manage sensitive data such as private keys and credentials.
- **Web3 Functionality:** Interact with Ethereum nodes and bundlers using web3 functions like `eth_call`, `eth_sendTransaction`, `eth_sendUserOperation`, etc.
- **PassKeyPair and HDWalletSigner:** Manage smart accounts signers using Passkeys or Seed Phrases.

## Getting Started

### Installation

```yml
// Add this line to your pubspec.yaml file

dependencies:
  variance_dart: ^0.0.4
```

Then run:

```sh
flutter pub get
```

### Usage

```dart
// Import the package
import 'package:variance_dart/utils.dart';
import 'package:variance_dart/variance.dart';

// optionally
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart';
```

configure your chains: there are 2 ways to get the chain configuration. either manually or using the already supported configurations.

```dart
Chain chain;

// manually
const String rpcUrl = 'http://localhost:8545';
const String bundlerUrl = 'http://localhost:3000/rpc';

chain = Chain(
    ethRpcUrl: rpcUrl,
    bundlerUrl: bundlerUrl,
    entrypoint: Constants.entrypoint,
    accountFactory: Constants.accountFactory,
    chainId: 1337,
    explorer: "");

// using pre configured chain
chain = Chains.getChain(Network.localhost)
    ..ethRpcUrl = rpcUrl
    ..bundlerUrl = bundlerUrl;
```

In order to create a smart wallet client you need to set up a signer, which will sign useroperation hashes to be verified onchain.
there are  3 available signers:

- passkeys
- hd wallet
- simple credential (privatekey)

> Variance SDK can be used to create both EOA and Smart Wallets. the `HD wallet signer` itself is a fully featured EOA wallet that can be used to build any EOA wallet like metamask. it can also be used as an account signer for a smart wallet.

```dart
// create smart wallet signer based of seed phrase
final HDWalletSigner hd = HDWalletSigner.createWallet();
print("mnemonic: ${hd.exportMnemonic()}");

// create a smart wallet signer based on passkeys
// this operation requires biometrics verification from the user
final PassKeyPair pkp =
    await PassKeySigner("myapp.xyz", "myapp", "https://myapp.xyz")
        .register("<user name>", true);
print("pkp: ${pkp.toJson()}");
```

Optionally the credentials returned from the signer instances can be securely saved on device android encrypted shared preferences or ios keychain using the `SecureStorageMiddleware`.

```dart
// save a signer credential to device
await hd
    .withSecureStorage(FlutterSecureStorage())
    .saveCredential(CredentialType.hdwallet);

await pkp
    .withSecureStorage(FlutterSecureStorage())
    .saveCredential(CredentialType.passkeypair);

// load a credential from the device
final ss = SecureStorageMiddleware(secureStorage: FlutterSecureStorage());
final hdInstance =
    await HDWalletSigner.loadFromSecureStorage(storageMiddleware: ss);
print("pkp: ${hdInstance?.exportMnemonic()}");

// NOTE: interactions with securestorage can be authenticated when using `SecureStorageMiddleware`

final ss = SecureStorageMiddleware(secureStorage: FlutterSecureStorage(), authMiddleware: AuthenticationMiddleware());
// then used with `SecureStorageMiddleware` in the following way

ss.save("key", "value", options: SSAuthOperationOptions(requiresAuth: true, authReason: "reason"));
ss.read("key"); // default options are used i.e requiresAuth: false
ss.delete("key", options: SSAuthOperationOptions(requiresAuth: false)); // explicitly reject authentication
```

Interacting with the smart wallet:

```dart
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


// utility function to convert eth amount from string to wei
EtherAmount getConversion(String amount) {
  final amtToDb = double.parse(amount);
  return EtherAmount.fromBigInt(
      EtherUnit.wei, BigInt.from(amtToDb * pow(10, 18)));
}
```

For detailed usage and examples, refer to the [documentation](https://docs.variance.space). Additional refer to the [demo](https://github.com/vaariance/variancedemo) for use in a flutter app.

## API Reference

Detailed API reference and examples can be found in the [API reference](https://pub.dev/documentation/variance_dart/latest/variance/variance-library.html).

## Contributing

We are committed to maintaining variance as an open source sdk, take a look at existing issues, open a pull request etc.

## License

This project is licensed under the **BSD-3-Clause** - see the [LICENSE](./LICENSE) file for details.
