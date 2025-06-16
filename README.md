# Variance SDK

Variance is a comprehensive toolkit for Ethereum Account Abstraction development, streamlining the creation and management of smart accounts and their interactions with Entrypoints. Built on top of the [Web3dart](https://pub.dev/packages/web3dart) library, it provides a robust foundation for blockchain development.

## Features

- **Smart Contract Integration:** Seamlessly handle ABI encoding and decoding for smooth interaction with Solidity smart contracts and the Entrypoint.
- **Streamlined Operations:** Build and execute UserOperations with minimal complexity
- **Token Management:** Comprehensive support for ERC20 and ERC721 token operations, from transfers to approvals
- **RPC Connectivity:** Direct interface with Ethereum networks and bundler services
- **Advanced Authentication:** Enable secure transaction signing using Passkeys.

## Getting Started

### Installation

open your terminal and run the following command:

```sh
flutter pub add variance_dart
flutter pub add web3_signers
flutter pub add web3dart
```

### Usage

```dart
// Import the packages
import 'package:web3_signers/web3_signers.dart';
import 'package:variance_dart/variance_dart.dart';
import 'package:web3dart/web3dart.dart';
```

### Chain Configuration

```dart
const bundler = "https://api.pimlico.io/v2/84532/rpc?apikey=API_KEY";

final Chain chain = Chain(
            bundlerUrl: bundler,
            paymasterUrl: bundler,
            testnet: true,
            chainId: 84532,
            jsonRpcUrl: "https://sepolia.base.org",
            accountFactory: Addresses.safeProxyFactoryAddress,
            explorer: "https://base-sepolia.blockscout.com/",
            entrypoint: EntryPointAddress.v07);
```

When creating Safe/Modular Accounts, specify `Addresses.safeProxyFactoryAddress` as the account factory address.
When creating LightAccounts, specify `Addresses.lightAccountFactoryAddress` as the account factory address.

The SDK supports all EVM compatible networks.

Paymaster Configuration:

- By default, no paymaster is configured (null)
- To enable paymaster functionality, provide the paymaster's RPC endpoint when setting up your smart wallet
- Additional paymaster settings can be configured after wallet creation:

```dart
wallet.paymasterAddress = EthereumAddress.fromHex("0x");
wallet.paymasterContext = {'key': 'value'};
```

### Signers

Creating a smart wallet client requires configuring a signer to validate useroperation hashes on-chain. The signer must be from the [web3signers](https://pub.dev/packages/web3_signers) package.

> Each account type requires a specific signer configuration:

1. `PrivateKeys` - Compatible with all account types
2. `Passkey` - Specifically for Safe Passkey and modular accounts
3. `EOA Wallet (seed phrases)` - Compatible with all account types

Visit the [web3signers](https://pub.dev/packages/web3_signers) documentation for complete implementation details.

### Smart Wallet Factory

Before creating a smart wallet instance, initialize a SmartWalletFactory using your chain configuration and signer (configured in the steps above).

```dart
final SmartWalletFactory smartWalletFactory = SmartWalletFactory(chain, signer);
```

### To Create an Alchemy Light Account

When using an [Alchemy Light Account](https://accountkit.alchemy.com/smart-contracts/light-account), you must configure your signer with a signature prefix. Add a `Uint8` prefix value when initializing your web3_signer - this prefix will be automatically included in all signatures generated for your smart wallet.
Example:

```dart
// prefix is required for alchemy light accounts
final salt = Uint256.zero;
const prefix = const SignatureOptions(prefix: [0])
final signer = EOAWallet.createWallet(WordLength.word_12, prefix);
final smartWalletFactory = SmartWalletFactory(chain, signer);

final Smartwallet wallet = await smartWalletFactory.createAlchemyLightAccount(salt);
print("light account wallet address: ${wallet.address.hex}");
```

### To create a [Safe](https://safe.global) Smart Account

```dart
final salt = Uint256.zero;
final signer = EOAWallet.createWallet();
final smartWalletFactory = SmartWalletFactory(chain, signer);

final Smartwallet wallet = await smartWalletFactory.createSafeAccount(salt);
print("safe wallet address: ${wallet.address.hex}");
```

> For all safe accounts including modular accounts, the `safeSingleton` address can be customized during account creation. If not specified, it defaults to `SafeSingletonAddress.l1` for mainnet or `SafeSingletonAddress.l2` for L2 chains.

### To create a [Safe](https://safe.global) Smart Account with Passkey

```dart
final salt = Uint256.zero;
final options = PassKeysOptions(
          name: "domain",
          namespace: "domain.com",
          authenticatorAttachment: "cross-platform",
          sharedWebauthnSigner: Addresses.sharedSignerAddress,
        );
final signer = PassKeySigner(options: options);
final smartWalletFactory = SmartWalletFactory(chain, signer);
final keypair = await signer.register(name, displayName); // email can be used in place of name

final Smartwallet wallet = await smartWalletFactory.createSafeAccountWithPasskey(
           keypair, salt);
print("p256 wallet address: ${wallet.address.hex}");
```

> The `PassKeyPair` object, obtained during registration with your `PasskeySigner`, is required for this operation.
> It is recommended serialize and persist the keypair for later use in your application.

### To create a [Modular Safe](https://docs.safe.global/advanced/erc-7579/7579-safe) Smart Account

 For more details about the technical specifications and implementation, visit [ERC7579](https://erc7579.com/) and [Rhinestone](https://rhinestone.dev).

 To access all available modules, install the `variance_modules` package by running: `flutter pub add variance_modules`

```dart
final salt = Uint256.zero;
final launchpad =
        EthereumAddress.fromHex("0x7579011aB74c46090561ea277Ba79D510c6C00ff");
    final attester =
        EthereumAddress.fromHex("0x000000333034E9f539ce08819E12c1b8Cb29084d");
final signer = EOAWallet.createWallet();

final smartWalletFactory = SmartWalletFactory(chain, signer);

final Smartwallet wallet = await smartWalletFactory.createSafe7579Account(salt, launchpad,
              attesters: [attester], attestersThreshold: 1);
print("safe wallet address: ${wallet.address.hex}");
```

> For all Modular Accounts, Additional modules (`validator`, `hooks`, `executors`, or `fallback`) can be initialized during account creation. For Passkey-enabled accounts, the `WebAuthnValidator` module must be included during initialization.

### To create a [Modular Safe](https://docs.safe.global/advanced/erc-7579/7579-safe) Smart Account with Passkey

Note that you must initialize the `WebAuthnValidator` module when creating the safe account.

```dart
import 'package:variance_modules/modules.dart';

final salt = Uint256.zero;
final options = PassKeysOptions(
          name: "domain",
          namespace: "domain.com",
          authenticatorAttachment: "cross-platform",
          sharedWebauthnSigner: Addresses.sharedSignerAddress,
        );

final signer = PassKeySigner(options: options);
final smartWalletFactory = SmartWalletFactory(chain, signer);

final keypair = await signer.register(name, displayName); 
final launchpad =
        EthereumAddress.fromHex("0x7579011aB74c46090561ea277Ba79D510c6C00ff");
    final attester =
        EthereumAddress.fromHex("0x000000333034E9f539ce08819E12c1b8Cb29084d");
final signer = EOAWallet.createWallet();

final smartWalletFactory = SmartWalletFactory(chain, signer);

Smartwallet wallet = await smartWalletFactory.createSafe7579AccountWithPasskey(
              keypair, salt, launchpad,
              attesters: [attester],
              attestersThreshold: 1,
              validators: List.from([
                ModuleInit(WebauthnValidator.getAddress(),
                    WebauthnValidator.parseInitData(BigInt.one, {keypair}))
              ]));

final validator = WebauthnValidator(wallet, BigInt.one, {keyPair});
// replace the wallet to allow for validator to trigger at least for initial transaction
wallet = validator.txService;
print("safe wallet address: ${wallet.address.hex}");
```

> To set up multi-signature functionality (threshold > 1), specify the threshold in the `ModuleInit` object. Note that all required `keypairs` must be available to sign user operations when using multiple signatures.

!!! CAVEATS

When working with Safe 7579 accounts and WebAuthn validation:

1. You must initialize the `WebAuthnValidator` module during account creation
2. For the first transaction, use the validator's txService instead of the base wallet. This is required because:
   - Safe 7579 accounts need an initial transaction to complete setup
   - The [Shared Signer](https://github.com/safe-global/safe-modules/tree/main/modules/passkey/contracts/4337) cannot be used until after this setup

### Interacting with the Smart Wallet

```dart
// retrieve the balance of a smart wallet
final EtherAmount balance = await wallet.balance;
print("account balance: ${balance.getInWei}");

// retrive the account nonce
Uint256 nonce = await wallet.getNonce();
// you can also retrieve a nonce with key
nonce = await wallet.getNonce(key: '<Uint256 instance>');
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

### Module Operations

> all modules can be installed from `variance_modules` package. simply run `flutter pub add variance_modules` to add the package to your project.
> Additionally, you must already have an instance of the smart wallet.

```dart
import 'package:variance_modules/modules.dart';

// required constructor parameters
final threshold = BigInt.two;
final  guardian1 = PrivateKeySigner.createRandom("guardian1 password");
final  guardian2 = PrivateKeySigner.createRandom("guardian2 password");

// create a new instance of the module
final module = SocialRecovery(smartWallet, threshold, [guardian1.address, guardian2.address]);

// get the module address
final address = module.address;
// get the module init data
final initData = module.initData;
// get the module name
final name = module.name;
// get the module version
final version = module.version;
// get the module type
final type = module.type;

// install the module
final receipt = await smartWallet.installModule(
    module.type,
    module.address,
    module.getInitData(),
  );
// uninstall the module
final receipt = await smartWallet.uninstallModule(
    module.type,
    module.address,
    await module.getDeInitData(), // you can pass additional data needed for deInitialization
  );
```

> each module contains its own specialized functionality and methods that are specific to that module's purpose.
> For validator modules, transactions requiring validation must be initiated through the validator instance rather than directly from the smart wallet. An example implementation is shown below.

```dart
// This example demonstrates how to add WebAuthn validation capabilities to an existing modular account.
// The account must support module installation (be modular).
// Note: A PassKey signer is required - create one if the account doesn't already use PassKey authentication.
final signer = PassKeySigner(options: PassKeysOptions(
          name: "domain",
          namespace: "domain.com",
          authenticatorAttachment: "cross-platform",
          sharedWebauthnSigner: Addresses.sharedSignerAddress,
        ));
final keypair = await signer.register(name, displayName); 
final validator = WebauthnValidator(account, BigInt.one, {keyPair}, signer);

// we need to install it first from the smartwallet.
await account.installModule(
    validator.type,
    validator.address,
    validator.getInitData(), // you can pass additional data needed for deInitialization
  );

// mint an nft using a passkey signature
final nft = EthereumAddress.fromHex("0x"); // add nft contract address
final mintAbi = ContractAbis.get("ERC721_SafeMint");
final mintCall = Contract.encodeFunctionCall("safeMint", nft, mintAbi);
// this transaction must be sent directly from the `validator.txService` instead.
// validators are responsible for validating userOperations and managing signature generation internally
final tx = await validator.txService.sendTransaction(nft, mintCall);
final receipt = await tx.wait();
```

> Note: When using the `WebauthnValidator` module, your account must either already use a passkey signer or you'll need to create one.
> Unlike validators, executors and hooks do not need to be used to process transactions. Use the default `SmartWallet` instance to send transactions.

For detailed usage and examples, refer to the [documentation](https://docs.variance.space). Additional refer to the [example](./example/) for use in a flutter app.

## API Reference

Detailed API reference and examples can be found in the [API reference](https://pub.dev/documentation/variance_dart/latest/variance/variance-library.html).

## Contributing

We are committed to maintaining variance as an open source sdk, take a look at existing issues, open a pull request etc.

## License

This project is licensed under the **BSD-3-Clause** - see the [LICENSE](./LICENSE) file for details.
