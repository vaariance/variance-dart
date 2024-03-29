part of 'interfaces.dart';

/// Abstract base class for interacting with an Bundler RPC provider.
///
/// Implementations of this class are expected to provide functionality for specifically interacting
/// with bundlers only.
abstract class RPCProviderBase implements RpcService {
  /// Asynchronously estimates the gas cost for a transaction to the specified address with the given calldata.
  ///
  /// Parameters:
  ///   - `to`: The [EthereumAddress] of the transaction recipient.
  ///   - `calldata`: The ABI-encoded data for the transaction.
  ///
  /// Returns:
  ///   A [Future] that completes with a [BigInt] representing the estimated gas cost.
  ///
  /// Example:
  /// ```dart
  /// var gasEstimation = await estimateGas(
  ///   EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   '0x0123456789abcdef',
  /// );
  /// ```
  /// This method uses an ethereum jsonRPC to estimate the gas cost for the specified transaction.
  Future<BigInt> estimateGas(
    EthereumAddress to,
    String calldata,
  );

  /// Asynchronously retrieves the current block number from the Ethereum node.
  ///
  /// Returns:
  ///   A [Future] that completes with an [int] representing the current block number.
  ///
  /// Example:
  /// ```dart
  /// var blockNumber = await getBlockNumber();
  /// ```
  /// This method uses an ethereum jsonRPC to fetch the current block number from the Ethereum node.
  Future<int> getBlockNumber();

  /// Asynchronously retrieves the EIP-1559 gas prices, including `maxFeePerGas` and `maxPriorityFeePerGas`.
  ///
  /// Returns:
  ///   A [Future] that completes with a [Map] containing the gas prices in [EtherAmount].
  ///
  /// Example:
  /// ```dart
  /// var gasPrices = await getEip1559GasPrice();
  /// ```
  /// This method uses an ethereum jsonRPC to fetch EIP-1559 gas prices from the Ethereum node.
  Future<Map<String, EtherAmount>> getEip1559GasPrice();

  /// Asynchronously retrieves the gas prices, supporting both EIP-1559 and legacy gas models.
  ///
  /// Returns:
  ///   A [Future] that completes with a [Map] containing the gas prices in [EtherAmount].
  ///
  /// Example:
  /// ```dart
  /// var gasPrices = await getGasPrice();
  /// ```
  /// This method first attempts to fetch EIP-1559 gas prices and falls back to legacy gas prices if it fails.
  Future<Map<String, EtherAmount>> getGasPrice();

  /// Asynchronously retrieves the legacy gas price from the Ethereum node.
  ///
  /// Returns:
  ///   A [Future] that completes with an [EtherAmount] representing the legacy gas price in [Wei].
  ///
  /// Example:
  /// ```dart
  /// var legacyGasPrice = await getLegacyGasPrice();
  /// ```
  /// This method uses an ethereum jsonRPC to fetch the legacy gas price from the Ethereum node.
  Future<EtherAmount> getLegacyGasPrice();

  /// Asynchronously sends an RPC call to the Ethereum node for the specified function and parameters.
  ///
  /// Parameters:
  ///   - `function`: The Ethereum RPC function to call. eg: `eth_getBalance`
  ///   - `params`: Optional parameters for the RPC call.
  ///
  /// Returns:
  ///   A [Future] that completes with the result of the RPC call.
  ///
  /// Example:
  /// ```dart
  /// var result = await send<String>('eth_getBalance', ['0x9876543210abcdef9876543210abcdef98765432']);
  /// ```
  Future<T> send<T>(String function, [List<dynamic>? params]);
}
