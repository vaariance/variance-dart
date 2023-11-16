part of 'package:variance_dart/interfaces.dart';

/// An abstract class representing the contract interface for an Ethereum Account Factory.
///
/// This class defines the common interface for interacting with an Ethereum smart contract
/// responsible for creating and managing accounts.
abstract class AccountFactoryBase {
  /// Retrieves the Ethereum address associated with a standard account.
  Future<EthereumAddress> getAddress(
    EthereumAddress owner,
    BigInt salt, {
    BlockNum? atBlock,
  });

  /// Retrieves the Ethereum address associated with a passkey account.
  Future<EthereumAddress> getPasskeyAccountAddress(
    Uint8List credentialHex,
    BigInt x,
    BigInt y,
    BigInt salt, {
    BlockNum? atBlock,
  });

  /// Retrieves the Ethereum address associated with the simpleAccount contract.
  Future<EthereumAddress> simpleAccount({BlockNum? atBlock});

  /// Retrieves the Ethereum address associated with the simplePasskeyAccount contract.
  Future<EthereumAddress> simplePasskeyAccount({BlockNum? atBlock});
}
