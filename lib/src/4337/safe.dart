part of '../../variance.dart';

class _SafePlugin extends Safe4337Module implements Safe4337ModuleBase {
  _SafePlugin({
    required super.address,
    super.chainId,
    required super.client,
  });

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

  Uint8List _getEncodedSignature(String signature) {
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    String validAfter = currentTimestamp.toRadixString(16);
    validAfter = '0' * (12 - validAfter.length) + validAfter;

    String validUntil = (currentTimestamp + 3600).toRadixString(16);
    validUntil = '0' * (12 - validUntil.length) + validUntil;

    return hexToBytes('0x$validAfter$validUntil${signature.substring(2)}');
  }
}
