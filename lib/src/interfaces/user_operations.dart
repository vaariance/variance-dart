part of 'interfaces.dart';

/// Abstract base class representing a user operation.
///
/// Implementations of this class are expected to provide functionality for creating,
/// updating, and hashing user operations.
abstract class UserOperationBase {
  /// Address of the smart wallet.
  EthereumAddress get sender;

  /// Nonce of the Smart Account.
  BigInt get nonce;

  /// Initialization code for the Smart Account.
  Uint8List get initCode;

  /// Call data for execution in a user operation.
  Uint8List get callData;

  /// Maximum amount of gas that can be used for executing a user operation calldata.
  BigInt get callGasLimit;

  /// Maximum amount of gas that can be used for executing a user operation signature verification.
  BigInt get verificationGasLimit;

  /// Gas for executing a user operation pre-verification.
  BigInt get preVerificationGas;

  /// Maximum fee per gas for the contract call.
  BigInt get maxFeePerGas;

  /// EIP1559 priority fee per gas for the contract call.
  BigInt get maxPriorityFeePerGas;

  /// Signature of the user operation.
  String get signature;

  /// Details of the paymaster and data for the gas sponsorship.
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

  /// Validates the user operation fields for accuracy
  ///
  /// Parameters:
  ///   - `deployed`: Whether the user operation sender is deployed or not
  ///   - `initCode`: (optional) The initialization code of the user operation
  void validate(bool deployed, [String? initCode]);
}
