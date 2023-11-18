part of 'package:variance_dart/interfaces.dart';

/// Abstract base class for handling Ethereum Name Service (ENS) resolution.
///
/// This class provides methods to interact with ENS, including resolving
/// ENS names to addresses and formatting addresses.
abstract class ENSResolverBase {
  String? get ens;

  /// Gets the ENS name associated with the current address.
  ///
  /// Returns a [Future] that completes with the ENS name.
  Future<String?>? getEnsName();

  /// Converts an Ethereum address to its corresponding ENS name.
  ///
  /// - [address]: The Ethereum address to convert to an ENS name.
  ///
  /// Returns a [Future] that completes with the ENS name.
  Future<String?>? getEnsNameForAddress(EthereumAddress address);

  /// Returns a new [ENSResolver] instance with the specified [client].
  ENSResolverBase withClient(ChainBaseApiBase client);
}
