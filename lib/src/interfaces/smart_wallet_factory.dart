part of 'interfaces.dart';

abstract class SmartWalletFactoryBase {
  /// Recovers an existing Safe account at the specified address. This only works if the account is deployed.
  ///
  /// - [account] The Ethereum address of the Safe account to recover
  /// - [isSafe7579] Whether the account is a Safe7579 account (defaults to false)
  ///
  /// Returns a [SmartWallet] instance representing the recovered Safe account.
  Future<SmartWallet> recoverSafeAccount(
    EthereumAddress account, {
    bool isSafe7579 = false,
  });

  /// Creates a new Safe7579 account with the provided parameters.
  ///
  /// - [salt] A unique value used to generate the account address
  /// - [launchpad] The launchpad contract address used for account deployment
  /// - [singleton] Optional Safe singleton contract address
  /// - [validators] Optional list of validator modules to initialize
  /// - [executors] Optional list of executor modules to initialize
  /// - [fallbacks] Optional list of fallback modules to initialize
  /// - [hooks] Optional list of hook modules to initialize
  /// - [attesters] Optional list of attester addresses
  /// - [attestersThreshold] Optional threshold for required attestations
  /// Returns a [Future] that resolves to a [SmartWallet] instance representing
  /// the created Safe7579 account.
  Future<SmartWallet> createSafe7579Account(
    Uint256 salt,
    EthereumAddress launchpad, {
    SafeSingletonAddress? singleton,
    Iterable<ModuleInitType>? validators,
    Iterable<ModuleInitType>? executors,
    Iterable<ModuleInitType>? fallbacks,
    Iterable<ModuleInitType>? hooks,
    Iterable<EthereumAddress>? attesters,
    int? attestersThreshold,
  });

  /// Creates a new Safe7579 account using a passkey for authentication.
  ///
  /// - [keyPair] The passkey pair used for account authentication
  /// - [salt] A unique value used to generate the account address
  /// - [launchpad] The launchpad contract address used for account deployment
  /// - [p256Verifier] Optional P256 verification contract address
  /// - [singleton] Optional Safe singleton contract address
  /// - [validators] Optional list of validator modules to initialize
  /// - [executors] Optional list of executor modules to initialize
  /// - [fallbacks] Optional list of fallback modules to initialize
  /// - [hooks] Optional list of hook modules to initialize
  /// - [attesters] Optional list of attester addresses
  /// - [attestersThreshold] Optional threshold for required attestations
  ///
  /// Returns a [Future] that resolves to a [SmartWallet] instance representing
  /// the created Safe7579 account.
  Future<SmartWallet> createSafe7579AccountWithPasskey(
    PassKeyPair keyPair,
    Uint256 salt,
    EthereumAddress launchpad, {
    EthereumAddress? p256Verifier,
    SafeSingletonAddress? singleton,
    Iterable<ModuleInitType>? validators,
    Iterable<ModuleInitType>? executors,
    Iterable<ModuleInitType>? fallbacks,
    Iterable<ModuleInitType>? hooks,
    Iterable<EthereumAddress>? attesters,
    int? attestersThreshold,
  });

  /// Creates a new P256 account using the provided key pair and salt.
  ///
  /// - [PassKeyPair] is the key pair used to create the account.
  /// - [salt] is the salt value used in the account creation process.
  ///
  /// Returns a [Future] that resolves to a [SmartWallet] instance representing
  /// the created account.
  ///
  /// Throws an [ArgumentError] if the provided [keyPair] is not a
  /// [PassKeyPair] instance.
  Future<SmartWallet> createSafeAccountWithPasskey(
    PassKeyPair keyPair,
    Uint256 salt, {
    EthereumAddress? p256Verifier,
    SafeSingletonAddress? singleton,
  });

  /// Creates a new Safe account with the provided salt and optional owners and threshold.
  ///
  /// - [salt] is the salt value used in the account creation process.
  ///
  /// Returns a [Future] that resolves to a [SmartWallet] instance representing
  /// the created Safe account.

  Future<SmartWallet> createSafeAccount(
    Uint256 salt, [
    SafeSingletonAddress? singleton,
  ]);

  /// Creates a new light account with the provided salt and optional index.
  ///
  /// [salt] is the salt value used in the account creation process.
  ///
  /// Returns a [Future] that resolves to a [SmartWallet] instance representing
  /// the created light account.
  Future<SmartWallet> createAlchemyLightAccount(Uint256 salt);
}
