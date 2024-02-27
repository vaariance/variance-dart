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

  @Deprecated("packed in accountGasLimits from v0.7")
  BigInt get callGasLimit;

  @Deprecated("packed in accountGasLimits from v0.7")
  BigInt get verificationGasLimit;

  Uint8List get accountGasLimits;

  BigInt get preVerificationGas;

  @Deprecated("packed in gasFees from v0.7")
  BigInt get maxFeePerGas;

  @Deprecated("packed in gasFees from v0.7")
  BigInt get maxPriorityFeePerGas;

  Uint8List get gasFees;

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

  /// Creates a [UserOperation] by updating an existing operation gas params.
  ///
  /// Parameters:
  ///   - `opGas`: Optional parameter of type [UserOperationGas] for specifying gas-related information.
  ///   - `feePerGas`: Optional parameter of type [Map<String, EtherAmount>] for specifying maxFeePerGas and maxPriorityFeePerGas.
  ///
  /// Returns:
  ///   A [UserOperation] instance created from the provided map.
  ///
  /// Example:
  /// ```dart
  /// var map = UserOperation.partial(callData: Uint8List(0xabcdef)).toMap();
  /// var updatedUserOperation = UserOperation.update(
  ///   map,
  ///   opGas: UserOperationGas(callGasLimit: BigInt.from(20000000), ...),
  ///   // Other parameters can be updated as needed.
  /// );
  /// ```
  UserOperation updateOpGas(
      UserOperationGas? opGas, Map<String, EtherAmount>? feePerGas);
}
