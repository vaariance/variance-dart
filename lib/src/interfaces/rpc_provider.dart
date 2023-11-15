part of 'package:variance_dart/interfaces.dart';

/// Abstract base class for interacting with an Bundler RPC provider.
///
/// Implementations of this class are expected to provide functionality for specifically interacting 
/// with bundlers only.
abstract class RPCProviderBase implements RpcService {
  /// Estimates the gas cost of a transaction.
  ///
  /// - [to]: The address or contract to which the transaction is to be sent.
  /// - [calldata]: The calldata of the transaction.
  ///
  /// Returns the estimated gas cost in wei.
  Future<BigInt> estimateGas(
    EthereumAddress to,
    String calldata,
  );

  /// Returns the current block number.
  ///
  /// Returns a [Future] that completes with the current block number.
  Future<int> getBlockNumber();

  /// Returns the EIP1559 gas price in wei for a network.
  ///
  /// Returns a [Future] that completes with a [Map] containing the following keys:
  ///
  /// - `'maxFeePerGas'`: An [EtherAmount] representing the maximum fee per gas.
  /// - `'maxPriorityFeePerGas'`: An [EtherAmount] representing the maximum priority fee per gas.
  Future<Map<String, EtherAmount>> getEip1559GasPrice();

  /// Returns the gas price in wei for a network.
  ///
  /// Returns a [Future] that completes with a [Map] containing the following keys:
  ///
  /// - `'maxFeePerGas'`: An [EtherAmount] representing the maximum fee per gas.
  /// - `'maxPriorityFeePerGas'`: An [EtherAmount] representing the maximum priority fee per gas.
  Future<Map<String, EtherAmount>> getGasPrice();

  /// Returns the legacy gas price in wei for a network.
  ///
  /// Returns a [Future] that completes with an [EtherAmount] representing the legacy gas price.
  Future<EtherAmount> getLegacyGasPrice();

  /// Sends a transaction to the bundler RPC.
  ///
  /// - [function]: The method to call.
  /// - [params]: The parameters for the request (optional).
  ///
  /// Returns a [Future] that completes with an RPC response of a generic type [T].
  Future<T> send<T>(String function, [List<dynamic>? params]);
}
