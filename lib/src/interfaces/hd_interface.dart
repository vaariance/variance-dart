part of 'interfaces.dart';

/// An interface for hierarchical deterministic (HD) wallets.
///
/// This interface defines the basic contract for interacting with HD wallets,
/// allowing the creation of accounts, exporting mnemonic phrases, exporting
/// private keys, signing messages, and more.
abstract class HDInterface extends MultiSignerInterface {
  /// Adds an Ethereum account derived from the HD wallet using the specified [index].
  ///
  /// Parameters:
  /// - [index]: The index used to derive the Ethereum account.
  ///
  /// Returns the Ethereum address associated with the specified index.
  ///
  /// Example:
  /// ```dart
  /// final walletSigner = HDWalletSigner.recoverAccount('mnemonic phrase');
  /// final newAccount = walletSigner.addAccount(1);
  /// ```
  EthereumAddress addAccount(int index);

  /// Exports the mnemonic phrase associated with the HD wallet signer.
  ///
  /// Returns the mnemonic phrase.
  ///
  /// Example:
  /// ```dart
  /// final walletSigner = HDWalletSigner.recoverAccount('mnemonic phrase');
  /// final exportedMnemonic = walletSigner.exportMnemonic();
  /// ```
  String? exportMnemonic();

  /// Exports the private key associated with the Ethereum account derived from the HD wallet using the specified [index].
  ///
  /// Parameters:
  /// - [index]: The index used to derive the Ethereum account.
  ///
  /// Returns the exported private key as a hexadecimal string.
  ///
  /// Example:
  /// ```dart
  /// final walletSigner = HDWalletSigner.recoverAccount('mnemonic phrase');
  /// final exportedPrivateKey = walletSigner.exportPrivateKey(1);
  /// ```
  String exportPrivateKey(int index);
}
