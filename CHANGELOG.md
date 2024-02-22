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
