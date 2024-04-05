## 0.1.0-r3

* Add mutisend address to constants
* Add support for Safe account batch transactions

## 0.1.0-r2

* Fix safe transaction encoding
* Remove _checkDeployment function in counterfactual creation
* Add getBlockInformation in JsonRPCProvider

## 0.1.0-r1

* Mainnet Pre-release
* refactor sdk to use the factory method for creating smart-accounts
* add safe smart accounts via safe plugin
* reduce external dependencies to 3
* implement custom errors and add logger for debugging
* update contract abis, adding more erc20/erc721 abi snippets
* fix paymaster plugin context incompatibility
* add utility for packing and unpacking uint256 values
* update chain configuration to surpport minimal modest chains
* update example to a real flutter example
* rename library name from variance to variance_dart for consistency
* update API refs and README to reflect new changes

## 0.0.9

* Add support for entrypoint v0.7 in parrallel.

## 0.0.8

* Add paymaster as a plugin
* Rename plugins.dart to mixins
* Improve gas and nonce calculation process.

## 0.0.7

* Deprecate passing wallet address via constructor as fields will be made final
* Enable global gas settings and fee % multiplier
* Introduce userOp retry mechanism

## 0.0.6

* Sunset all goerli chains

## 0.0.5

* Added missing required blockParam to `eth_call`

* Reduced default callgasLimit and verificationGasLimit to 250K and 750k respectively in `eth_estimateUserOperationGas`

* Prevent redundant eth_call's in fetching nonce/deployment status

* Reduced strict internal op callGasLimit validation from 21k gas 12k gas requirement

## 0.0.4

* Added a Secure Storage Repository for saving credentials to encrypted android shared-preference and iOS keychain

* Biometric Auth layer over the secure storage repository

* Retrieve account nonce from Entrypoint instead of account contract using zeroth key.

* fixed userOp hashing and added compulsory dummySignature field to account signer interface.

* Bug Fixes

## 0.0.3

* Temporarily removed support for internally handling local authentication and credential storage in the hd signer

## 0.0.1

* Create SmartWallet class using simple accounts

* Initial Implementation of the Bundler Providers

* Multi-Signer Interface with Passkey support for signing User Operations
