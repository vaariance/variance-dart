part of '../../variance_dart.dart';

/// Packs two 128-bit unsigned integers into a 32-byte array.
///
/// Parameters:
/// - [high128]: The high 128-bit unsigned integer.
/// - [low128]: The low 128-bit unsigned integer.
///
/// Returns a Uint8List containing the packed bytes.
///
/// Example:
/// ```dart
/// final high128 = BigInt.from(1);
/// final low128 = BigInt.from(2);
/// final packedBytes = packUints(high128, low128);
/// print(packedBytes);
/// ```
Uint8List packUints(BigInt high128, BigInt low128) {
  final shiftedHigh = high128 << 128;
  final combined = shiftedHigh + low128;
  return hexToBytes(combined.toRadixString(16).padLeft(64, '0'));
}

/// Unpacks two 128-bit unsigned integers from a 32-byte array.
///
/// Parameters:
/// - [bytes]: The 32-byte array containing the packed bytes.
///
/// Returns a list containing the unpacked high and low 128-bit unsigned integers.
///
/// Example:
/// ```dart
/// final bytes = Uint8List.fromList([0x01, 0x02, 0x03, 0x04]);
/// final unpacked = unpackUints(bytes);
/// print(unpacked);
/// ```
List<BigInt> unpackUints(Uint8List bytes) {
  final hex = bytesToHex(bytes);
  final value = BigInt.parse(hex, radix: 16);
  final mask =
      BigInt.from(0xFFFFFFFFFFFFFFFF) << 64 | BigInt.from(0xFFFFFFFFFFFFFFFF);
  return [value >> 128, value & mask];
}

/// Packs a [UserOperation] into a PackedUserOperation map for EntryPoint v0.7 and above.
///
/// Parameters:
/// - [userOp]: The [UserOperation] to pack.
///
/// Returns a [Map] containing the packed user operation.
///
/// Example:
/// ```dart
/// final userOp = UserOperation(
///   sender: EthereumAddress.fromHex('0x1234567890123456789012345678901234567890'),
///   nonce: BigInt.from(1),
///   initCode: Uint8List(0),
///   callData: Uint8List(0),
///   callGasLimit: BigInt.from(2),
///   verificationGasLimit: BigInt.from(3),
///   preVerificationGas: BigInt.from(4),
///   maxFeePerGas: BigInt.from(5),
///   maxPriorityFeePerGas: BigInt.from(6),
///   signature: '0x1234567890123456789012345678901234567890',
///   paymasterAndData: Uint8List(0),
/// );
/// final packedUserOp = packUserOperation(userOp);
/// print(packedUserOp);
/// ```
Map<String, dynamic> packUserOperation(UserOperation userOp) {
  return {
    'sender': userOp.sender.hex,
    'nonce': '0x${userOp.nonce.toRadixString(16)}',
    'initCode': hexlify(userOp.initCode),
    'callData': hexlify(userOp.callData),
    'accountGasLimits':
        hexlify(packUints(userOp.verificationGasLimit, userOp.callGasLimit)),
    'preVerificationGas': '0x${userOp.preVerificationGas.toRadixString(16)}',
    'gasFees':
        hexlify(packUints(userOp.maxPriorityFeePerGas, userOp.maxFeePerGas)),
    'signature': userOp.signature,
    'paymasterAndData': hexlify(userOp.paymasterAndData),
  };
}
