part of 'package:variance_dart/interfaces.dart';

/// Abstract base class for handling Ethereum Name Service (ENS) resolution.
///
/// This class provides methods to interact with ENS, including resolving
/// ENS names to addresses and formatting addresses.
abstract class ENSResolverBase {
  String? get ens;

  /// Gets the ENS name associated with the current address.
  ///
  /// - [ethRpc]: The Ethereum RPC endpoint URL (optional).
  ///
  /// Returns a [Future] that completes with the ENS name.
  Future<String> getEnsName({String? ethRpc});

  /// Converts an Ethereum address to its corresponding ENS name.
  ///
  /// - [address]: The Ethereum address to convert to an ENS name.
  /// - [ethRpc]: The Ethereum RPC endpoint URL (optional).
  ///
  /// Returns a [Future] that completes with the ENS name.
  Future<String> getEnsNameForAddress(String address, {String? ethRpc});
}
