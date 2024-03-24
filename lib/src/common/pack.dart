part of '../../variance.dart';

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

List<BigInt> unpackUints(Uint8List bytes) {
  final hex = bytesToHex(bytes);
  final value = BigInt.parse(hex, radix: 16);
  final mask =
      BigInt.from(0xFFFFFFFFFFFFFFFF) << 64 | BigInt.from(0xFFFFFFFFFFFFFFFF);
  return [value >> 128, value & mask];
}
