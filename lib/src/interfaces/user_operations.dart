part of 'interfaces.dart';

/// Abstract base class representing a user operation.
///
/// Implementations of this class are expected to provide functionality for creating,
/// updating, and hashing user operations.
abstract class UserOperationBase {
  EthereumAddress get sender;

  BigInt get nonce;

  Uint8List get initCode;

  Uint8List get callData;

  BigInt get callGasLimit;

  BigInt get verificationGasLimit;

  BigInt get preVerificationGas;

  BigInt get maxFeePerGas;

  BigInt get maxPriorityFeePerGas;

  String get signature;

  Uint8List get paymasterAndData;

  /// Hashes the user operation for the given chain.
  ///
  /// - [chain]: The chain for which to hash the user operation.
  ///
  /// Returns a [Uint8List] representing the hashed user operation.
  Uint8List hash(Chain chain);

  /// Converts the user operation to a JSON-encoded string.
  String toJson();

  /// Converts the user operation to a map.
  ///
  /// Returns a [Map] representing the user operation.
  Map<String, dynamic> toMap();
}
