part of 'interfaces.dart';

/// Abstract base class representing a provider for interacting with an entrypoint.
///
/// Implementations of this class are expected to provide functionality for interacting specifically
/// with bundlers and provides methods for sending user operations to an entrypoint.
abstract class BundlerProviderBase {
  /// Set of Ethereum RPC methods supported by a 4337 bundler.
  static final Set<String> methods = {
    'eth_chainId',
    'eth_sendUserOperation',
    'eth_estimateUserOperationGas',
    'eth_getUserOperationByHash',
    'eth_getUserOperationReceipt',
    'eth_supportedEntryPoints',
    'pm_sponsorUserOperation'
  };

  /// Asynchronously estimates the gas cost for a user operation using the provided data and entrypoint.
  ///
  /// Parameters:
  ///   - `userOp`: A map containing the user operation data.
  ///   - `entrypoint`: The [EntryPoint] representing the entrypoint for the operation.
  ///
  /// Returns:
  ///   A [Future] that completes with a [UserOperationGas] instance representing the estimated gas values.
  ///
  /// Example:
  /// ```dart
  /// var gasEstimation = await estimateUserOperationGas(
  ///   myUserOp, // Map<String, dynamic>
  ///   EthereumAddress.fromHex('0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789'),
  /// );
  /// ```
  /// This method uses the bundled RPC to estimate the gas cost for the provided user operation data.
  Future<UserOperationGas> estimateUserOperationGas(
      Map<String, dynamic> userOp, EntryPoint entrypoint);

  /// Asynchronously retrieves information about a user operation using its hash.
  ///
  /// Parameters:
  ///   - `userOpHash`: The hash of the user operation to retrieve information for.
  ///
  /// Returns:
  ///   A [Future] that completes with a [UserOperationByHash] instance representing the details of the user operation.
  ///
  /// Example:
  /// ```dart
  /// var userOpDetails = await getUserOperationByHash('0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef');
  /// ```
  /// This method uses the bundled RPC to fetch information about the specified user operation using its hash.
  Future<UserOperationByHash> getUserOperationByHash(String userOpHash);

  /// Asynchronously retrieves the receipt of a user operation using its hash.
  ///
  /// Parameters:
  ///   - `userOpHash`: The hash of the user operation to retrieve the receipt for.
  ///
  /// Returns:
  ///   A [Future] that completes with a [UserOperationReceipt] instance representing the receipt of the user operation.
  ///
  /// Example:
  /// ```dart
  /// var userOpReceipt = await getUserOpReceipt('0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef');
  /// ```
  /// This method uses the bundled RPC to fetch the receipt of the specified user operation using its hash.
  Future<UserOperationReceipt> getUserOpReceipt(String userOpHash);

  /// Asynchronously sends a user operation to the bundler for execution.
  ///
  /// Parameters:
  ///   - `userOp`: A map containing the user operation data.
  ///   - `entrypoint`: The [EntryPoint] representing the entrypoint for the operation.
  ///
  /// Returns:
  ///   A [Future] that completes with a [UserOperationResponse] containing information about the executed operation.
  ///
  /// Example:
  /// ```dart
  /// var response = await sendUserOperation(
  ///   myUserOp, // Map<String, dynamic>
  ///   EthereumAddress.fromHex('0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789'),
  /// );
  /// ```
  /// This method uses the bundled RPC to send the specified user operation for execution and returns the response.
  Future<UserOperationResponse> sendUserOperation(
      Map<String, dynamic> userOp, EntryPoint entrypoint);

  /// Asynchronously retrieves a list of supported entrypoints from the bundler.
  ///
  /// Returns:
  ///   A [Future] that completes with a list of supported entrypoints as strings.
  ///
  /// Example:
  /// ```dart
  /// var entrypoints = await supportedEntryPoints();
  /// ```
  Future<List<String>> supportedEntryPoints();

  /// Validates if the provided method is a supported RPC method.
  ///
  /// Parameters:
  ///   - `method`: The Ethereum RPC method to validate.
  ///
  /// Throws:
  ///   - A [Exception] if the method is not a valid supported method.
  ///
  /// Example:
  /// ```dart
  /// validateBundlerMethod('eth_sendUserOperation');
  /// ```
  static validateBundlerMethod(String method) {
    assert(methods.contains(method), InvalidBundlerMethod(method));
  }
}
