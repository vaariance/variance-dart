part of 'interfaces.dart';

/// Abstract base class for interacting with an Bundler RPC provider.
///
/// Implementations of this class are expected to provide functionality for specifically interacting
/// with bundlers only.
abstract class JsonRPCProviderBase {
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

  /// Asynchronously retrieves information about the specified block.
  /// If no block number is provided, it defaults to the latest block.
  /// If `isContainFullObj` is set to `true`, the full block object will be returned.
  ///
  /// Parameters:
  ///   - `blockNumber`: The block number to retrieve information for.
  ///   - `isContainFullObj`: Whether to return the full block object.
  ///
  /// Returns:
  ///   A [Future] that completes with a [BlockInformation] object containing the block information.
  ///
  /// Example:
  /// ```dart
  /// var blockInfo = await getBlockInformation();
  /// ```
  Future<BlockInformation> getBlockInformation({
    String blockNumber = 'latest',
    bool isContainFullObj = true,
  });

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
}
