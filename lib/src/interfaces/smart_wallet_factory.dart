part of 'interfaces.dart';

abstract class SmartWalletFactoryBase {}

abstract class SmartWalletFactoryOld {
  /// Asynchronously creates a simple Ethereum smart account using the provided salt value.
  /// Uses counterfactactual deployment to create the account and [isDeployed] should be used to check deployment status.
  /// An `initCode` will be attached on the first transaction.
  ///
  /// Parameters:
  ///   - `salt`: A [Uint256] representing the salt value for account creation.
  ///   - `index`: Optional parameter specifying the index for selecting a signer. Defaults to `null`.
  ///
  /// Returns:
  ///   A [Future] that completes with the created [SmartWallet] instance.
  ///
  /// Example:
  /// ```dart
  /// var smartWallet = await createSimpleAccount(Uint256.zero, index: 1);
  /// ```
  /// This method generates initialization calldata using the 'createAccount' method and the provided signer and salt.
  /// It then retrieves the Ethereum address for the simple account and sets it to the wallet instance.
  Future createSimpleAccount(Uint256 salt, {int? index});

  /// Asynchronously creates a simple Ethereum smart account using a passkey pair and the provided salt value.
  ///
  /// Parameters:
  ///   - `pkp`: A [PassKeyPair] representing the passkey pair for account creation.
  ///   - `salt`: A [Uint256] representing the salt value for account creation.
  ///
  /// Returns:
  ///   A [Future] that completes with the created [SmartWallet] instance.
  ///
  /// Example:
  /// ```dart
  /// var smartWallet = await createSimplePasskeyAccount(myPassKeyPair, Uint256.zero);
  /// ```
  /// This method generates initialization calldata using the 'createPasskeyAccount' method and the provided
  /// passkey pair and salt. The passkey pair includes the credential and public key values.
  Future createLightP256Account(PassKeyPair pkp, Uint256 salt);

  /// Asynchronously retrieves the Ethereum address for a simple account created with the specified signer and salt.
  ///
  /// Parameters:
  ///   - `signer`: The [EthereumAddress] of the signer associated with the account.
  ///   - `salt`: A [Uint256] representing the salt value used in the account creation.
  ///
  /// Returns:
  ///   A [Future] that completes with the Ethereum address of the simple account.
  ///
  /// Example:
  /// ```dart
  /// var address = await getSimpleAccountAddress(
  ///   EthereumAddress.fromHex('0x1234567890abcdef1234567890abcdef12345678'),
  ///   Uint256.zero,
  /// );
  /// ```
  Future<EthereumAddress> getSimpleAccountAddress(
      EthereumAddress signer, Uint256 salt);

  /// Asynchronously retrieves the Ethereum address for a simple account created with the specified passkey pair and salt.
  ///
  /// Parameters:
  ///   - `pkp`: The [PassKeyPair] used for creating the account.
  ///   - `salt`: A [Uint256] representing the salt value used in the account creation.
  ///
  /// Returns:
  ///   A [Future] that completes with the Ethereum address of the simple account.
  ///
  /// Example:
  /// ```dart
  /// var address = await getSimplePassKeyAccountAddress(
  ///   myPassKeyPair,
  ///   Uint256.zero,
  /// );
  /// ```
  Future<EthereumAddress> getSimplePassKeyAccountAddress(
      PassKeyPair pkp, Uint256 salt);
}
