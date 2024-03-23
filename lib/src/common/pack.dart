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
  if (high128 >= BigInt.two.pow(128) || low128 >= BigInt.two.pow(128)) {
    throw ArgumentError('Values exceed the range of 128-bit unsigned integers');
  }

  final high = high128.toRadixString(16).padLeft(32, '0');
  final low = low128.toRadixString(16).padLeft(32, '0');
  final packedBytes = hexToBytes('$high$low');
  return packedBytes;
}
