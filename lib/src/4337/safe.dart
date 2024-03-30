part of '../../variance.dart';

/// A class that extends the Safe4337Module and implements the Safe4337ModuleBase interface.
/// It provides functionality related to Safe accounts and user operations on an Ethereum-like blockchain.
class _SafePlugin extends Safe4337Module implements Safe4337ModuleBase {
  /// Creates a new instance of the _SafePlugin class.
  ///
  /// [address] is the address of the Safe 4337 module.
  /// [chainId] is the ID of the blockchain chain.
  /// [client] is the client used for interacting with the blockchain.
  _SafePlugin({
    required super.address,
    super.chainId,
    required super.client,
  });

  /// Computes the hash of a Safe UserOperation.
  ///
  /// [op] is an object representing the user operation details.
  ///
  /// Returns a Future that resolves to the hash of the user operation as a Uint8List.
  Future<Uint8List> getUserOperationHash(UserOperation op) async =>
      getOperationHash([
        op.sender,
        op.nonce,
        op.initCode,
        op.callData,
        op.callGasLimit,
        op.verificationGasLimit,
        op.preVerificationGas,
        op.maxFeePerGas,
        op.maxPriorityFeePerGas,
        op.paymasterAndData,
        _getEncodedSignature(op.signature)
      ]);

  /// Encodes the signature of a user operation with a validity period.
  ///
  /// [signature] is the signature of the user operation.
  ///
  /// Returns a Uint8List representing the encoded signature with a validity period.
  Uint8List _getEncodedSignature(String signature) {
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    String validAfter = currentTimestamp.toRadixString(16);
    validAfter = '0' * (12 - validAfter.length) + validAfter;

    String validUntil = (currentTimestamp + 3600).toRadixString(16);
    validUntil = '0' * (12 - validUntil.length) + validUntil;

    return hexToBytes('0x$validAfter$validUntil${signature.substring(2)}');
  }
}
