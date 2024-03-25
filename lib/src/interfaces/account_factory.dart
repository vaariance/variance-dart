part of 'interfaces.dart';

/// An abstract class representing the contract interface for an Ethereum Account Factory.
///
/// This class defines the common interface for interacting with an Ethereum smart contract
/// responsible for creating and managing accounts.
abstract class SimpleAccountFactoryBase {
  /// Retrieves the Ethereum address associated with a standard account.
  Future<EthereumAddress> getAddress(
    EthereumAddress owner,
    BigInt salt, {
    BlockNum? atBlock,
  });
}

abstract class P256AccountFactoryBase {
  /// Retrieves the Ethereum address associated with a standard p256 account.
  Future<EthereumAddress> getP256AccountAddress(
    BigInt salt,
    Uint8List creation, {
    BlockNum? atBlock,
  });
}
