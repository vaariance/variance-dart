# Variance SDK

Variance is a Dart SDK designed to simplify interaction with Ethereum-based blockchains and enables flutter developers to implement account abstraction with minimal efforts. It provides functionalities such as encoding and decoding ABI data, handling Ethereum transactions, working with ERC20 and ERC721 tokens, and managing Ethereum smart accounts.

## Features

- **ABI Encoding/Decoding:** Easily encode and decode ABI data for Ethereum smart contract and Entrypoint interactions.
- **Transaction Handling:** Simplify the process of creating and sending UserOperations.
- **Token Operations:** Work with ERC20 and ERC721 tokens, including transfer and approval functionalities.
- **Web3 Functionality:** Interact with Ethereum nodes and bundlers using abstracted methods over, `eth_sendTransaction`, and `eth_sendUserOperation`.
- **SecP256r1 Signatures:** Sign transactions with SecP256r1 signatures.

## Getting Started

### Installation

open your terminal and run the following command:

```sh
flutter pub add variance_dart
flutter pub add web3_signers

# optionally
flutter pub add web3dart
```

### Usage

```dart
// Import the package
import 'package:web3_signers/web3_signers.dart';
import 'package:variance_dart/variance_dart.dart';

// optionally
import 'package:web3dart/web3dart.dart';
```

### Chain Configuration

```dart
const String rpcUrl = 'http://localhost:8545';
const String bundlerUrl = 'http://localhost:3000/rpc';
const Uint256 salt = const Uint256.zero;

final Chain chain = Chains.getChain(Network.localhost)
    ..jsonRpcUrl = rpcUrl
    ..bundlerUrl = bundlerUrl;
```

> There are 8 available networks: ethereum, polygon, optimism, base, arbitrumOne, linea, opBnB and scroll. 3 available testnets: sepolia, mumbai and baseTestent. You can also develop on localHost.

Additionally, you can specify a different Entrypoint address. By default, the entrypoin v0.6 is used.

```dart
final EntryPointAddress entrypointAddress = EntryPointAddress.v07;
chain.entrypoint = entrypointAddress;
```

Also if wish to use paymasters with your smart wallet you can do so by specifying the endpoint of the paymaster. By default the paymaster is set to null. This would add a paymaster Plugin to the smart wallet.

```dart
final String paymasterUrl = 'https://api.pimlico.io/v2/84532/rpc?apikey=...';
chain.paymasterUrl = paymasterUrl;
```

If you have additional context for the paymaster, you will be able to add it to the smart wallet after creation or before initiating a transaction.

```dart
wallet.plugin<Paymaster>('paymaster').context = {'key': 'value'};
```

### Signers

In order to create a smart wallet client you need to set up a signer, which will sign useroperation hashes to be verified onchain. Only signers available in the [web3signers](https://pub.dev/packages/web3_signers) package can be used.

> You have to use the correct signer for the type of account you want to create.

1. `PrivateKeys` - use with light accounts and safe accounts only
2. `Passkey` - use with p256 smart accounts and safe Passkey accounts only
3. `EOA Wallet (Seed Phrases)` - use with light smart accounts and safe accounts only
4. `HardWare Signers (Secure Enclave/Keystore)` - use with p256 smart accounts only

### Smart Wallet Factory

The smart wallet factory handles the creation of smart wallet instances. Make sure you have created a signer from the previous step.

```dart
final SmartWalletFactory smartWalletFactory = SmartWalletFactory(chain, signer);
```

#### To Create an Alchemy Light Account

```dart
final Smartwallet wallet = await smartWalletFactory.createAlchemyLightAccount(salt);
print("light account wallet address: ${wallet.address.hex}");
```

#### To create a P256 Smart Account (Secure Enclave/Keystore)

```dart
final Smartwallet wallet = await smartWalletFactory.createP256Account(keypair, salt);
print("p256 wallet address: ${wallet.address.hex}");
```

Your keypair must be either be the `PassKeyPair` or `P256Credential` return when registering with your secp256r1 signer.
Additionally, you can pass a recovery address to the `createP256Account` method.

```dart
final Smartwallet wallet = await smartWalletFactory.createP256Account(keypair, salt, recoveryAddress);
print("p256 wallet address: ${wallet.address.hex}");
```

#### To create a [Safe](https://safe.global) Smart Account

```dart
final Smartwallet wallet = await smartWalletFactory
    .createSafeAccount(salt);
print("safe wallet address: ${wallet.address.hex}");
```

> Safe SecP256r1 signers can not be used with this SDK yet.

### Interacting with the Smart Wallet

```dart
// retrieve the balance of a smart wallet
final EtherAmount balance = await wallet.balance;
print("account balance: ${balance.getInWei}");

// retrive the account nonce
final Uint256 nonce = await wallet.nonce;
print("account nonce: ${nonce.toInt()}");

// check if a smart wallet has been deployed
final bool deployed = await wallet.deployed;
print("account deployed: $deployed");

// get the init code of the smart wallet
final String initCode = wallet.initCode;
print("account init code: $initCode");

// perform a simple transaction (send ether to another account)
// account must be prefunded with native token. paymaster is not yet implemented
await wallet.send(
  EthereumAddress.fromHex(
      "0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789"), // receive address
  EtherAmount.fromInt(EtherUnit.ether, 0.7142), // 0.7142 ether
);
```

For detailed usage and examples, refer to the [documentation](https://docs.variance.space). Additional refer to the [example](./example/) for use in a flutter app.

## API Reference

Detailed API reference and examples can be found in the [API reference](https://pub.dev/documentation/variance_dart/latest/variance/variance-library.html).

## Contributing

We are committed to maintaining variance as an open source sdk, take a look at existing issues, open a pull request etc.

## License

This project is licensed under the **BSD-3-Clause** - see the [LICENSE](./LICENSE) file for details.
