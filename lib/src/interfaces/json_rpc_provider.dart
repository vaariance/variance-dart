part of 'interfaces.dart';

enum GasEstimation {
  low(rate: 0),
  normal(rate: 1),
  high(rate: 2);

  final int rate;

  const GasEstimation({required this.rate});
}

/// Abstract base class for interacting with an Bundler RPC provider.
///
/// Implementations of this class are expected to provide functionality for specifically interacting
/// with bundlers only.
abstract class JsonRPCProviderBase {
  /// Asynchronously checks whether a smart contract is deployed at the specified address.
  ///
  /// Parameters:
  ///   - `address`: The [EthereumAddress] of the smart contract.
  ///   - `atBlock`: The [BlockNum] specifying the block to check for deployment. Defaults to the current block.
  ///
  /// Returns:
  ///   A [Future] that completes with a [bool] indicating whether the smart contract is deployed.
  ///
  /// Example:
  /// ```dart
  /// var isDeployed = await deployed(
  ///   EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   atBlock: BlockNum.exact(123456), // optional
  /// );
  /// ```
  /// This method uses an ethereum jsonRPC to check if a smart contract is deployed at the specified address.
  Future<bool> deployed(EthereumAddress? address,
      {BlockNum atBlock = const BlockNum.current()});

  /// Asynchronously retrieves the balance of an Ethereum address.
  ///
  /// Parameters:
  ///   - `address`: The [EthereumAddress] for which to retrieve the balance.
  ///   - `atBlock`: The [BlockNum] specifying the block at which to check the balance. Defaults to the current block.
  ///
  /// Returns:
  ///   A [Future] that completes with an [EtherAmount] representing the balance.
  ///
  /// Example:
  /// ```dart
  /// var balance = await getBalance(
  ///   EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   atBlock: BlockNum.exact(123456), // optional
  /// );
  /// ```
  /// This method uses an ethereum jsonRPC to  fetch the balance of the specified Ethereum address.
  Future<EtherAmount> balanceOf(EthereumAddress? address,
      {BlockNum atBlock = const BlockNum.current()});

  /// Asynchronously calls a function on a smart contract with the provided parameters.
  ///
  /// Parameters:
  ///   - `contractAddress`: The [EthereumAddress] of the smart contract.
  ///   - `abi`: The [ContractAbi] representing the smart contract's ABI.
  ///   - `methodName`: The name of the method to call on the smart contract.
  ///   - `params`: Optional parameters for the function call.
  ///   - `sender`: The [EthereumAddress] of the sender, if applicable.
  ///
  /// Returns:
  ///   A [Future] that completes with a list of dynamic values representing the result of the function call.
  ///
  /// Example:
  /// ```dart
  /// var result = await read(
  ///   EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432'),
  ///   myErc20ContractAbi,
  ///   'balanceOf',
  ///   params: [ EthereumAddress.fromHex('0x9876543210abcdef9876543210abcdef98765432')],
  /// );
  /// ```
  /// This method uses the an Ethereum jsonRPC to `staticcall` a function on the specified smart contract.
  /// **Note:** This method does not support contract calls with state changes.
  Future<List<dynamic>> readContract(
      EthereumAddress contractAddress, ContractAbi abi, String methodName,
      {List<dynamic>? params, EthereumAddress? sender});

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
  Future<Fee> getGasPrice([GasEstimation rate = GasEstimation.normal]);
}
