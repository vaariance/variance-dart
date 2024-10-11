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
  final packed = (high128 << 128) + low128;
  return hexToBytes('0x${packed.toRadixString(16).padLeft(64, '0')}');
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
/// final unpacked = unpackUints("0x...32byteshex");
/// print(unpacked);
/// ```
List<BigInt> unpackUints(String hex) {
  final value = BigInt.parse(hex.substring(2), radix: 16);
  return [value >> 128, value.toUnsigned(128)];
}
