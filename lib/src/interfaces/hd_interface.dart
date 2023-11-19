part of 'package:variance_dart/interfaces.dart';

/// An interface for hierarchical deterministic (HD) wallets.
///
/// This interface defines the basic contract for interacting with HD wallets,
/// allowing the creation of accounts, exporting mnemonic phrases, exporting
/// private keys, signing messages, and more.
abstract class HDInterface extends MultiSignerInterface {
  /// Adds a new account to the HD wallet.
  ///
  /// - [index]: The index of the account.
  ///
  /// Returns the Ethereum address of the new account.
  EthereumAddress addAccount(int index);

  /// Exports the mnemonic phrase associated with the HD wallet.
  ///
  /// Returns the mnemonic phrase as a [String].
  String? exportMnemonic();

  /// Exports the private key of an account from the HD wallet.
  ///
  /// - [index]: The index of the account.
  ///
  /// Returns the private key as a [String].
  String exportPrivateKey(int index);

  /// Retrieves the Ethereum address of an account from the HD wallet.
  ///
  /// - [index]: The index of the account.
  ///
  /// Returns the Ethereum address.
  EthereumAddress getEthereumAddress({int index = 0});
}
