part of 'package:variance_dart/interfaces.dart';

/// Abstract base class representing a provider for interacting with an entrypoint.
///
/// Implementations of this class are expected to provide functionality for interacting specifically
/// with bundlers and provides methods for sending user operations to an entrypoint.
abstract class BundlerProviderBase {
  /// The RPC provider associated with the bundler.
  RPCProviderBase get bundlerRpc;

  /// Estimates the gas cost for a user operation.
  ///
  /// - [userOp]: The user operation.
  /// - [entrypoint]: The entrypoint address through which the operation should pass.
  ///
  /// Returns a [Future] that completes with a [UserOperationGas] object.
  Future<UserOperationGas> estimateUserOperationGas(
      Map<String, dynamic> userOp, EthereumAddress entrypoint);

  /// Retrieves a user operation object associated with a userOpHash.
  ///
  /// - [userOpHash]: The hashed string of the user operation.
  ///
  /// Returns a [Future] that completes with a [UserOperationByHash] object.
  Future<UserOperationByHash> getUserOperationByHash(String userOpHash);

  /// Retrieves a user operation receipt associated with a userOpHash.
  ///
  /// - [userOpHash]: The hashed string of the user operation.
  ///
  /// Returns a [Future] that completes with a [UserOperationReceipt] object.
  Future<UserOperationReceipt> getUserOpReceipt(String userOpHash);

  /// Initializes the provider with an entrypoint.
  ///
  /// - [ep]: The entrypoint to initialize with.
  void initializeWithEntrypoint(Entrypoint ep);

  /// Sends a user operation to the given network.
  ///
  /// - [userOp]: The user operation.
  /// - [entrypoint]: The entrypoint address through which the operation should pass.
  ///
  /// Returns a [Future] that completes with a [UserOperationResponse] object.
  Future<UserOperationResponse> sendUserOperation(
      Map<String, dynamic> userOp, EthereumAddress entrypoint);

  /// Returns a list of supported entrypoints for the bundler.
  ///
  /// Returns a [Future] that completes with a list of supported entrypoints.
  Future<List<String>> supportedEntryPoints();

  /// Waits for a specified duration and returns a [FilterEvent] based on an event emitted by the smart contract.
  ///
  /// - [millisecond]: The duration to wait in milliseconds.
  ///
  /// Returns a [Future] that completes with a [FilterEvent] or `null`.
  Future<FilterEvent?> wait({int millisecond});
}
