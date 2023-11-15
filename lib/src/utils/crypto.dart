part of 'package:variance_dart/utils.dart';

/// Converts the given hex string [hexString] to its corresponding 32 bytes [Uint8List] representation.
///
/// - [hexString]: The hex string to convert.
///
/// Returns a [Uint8List] representing the converted bytes.
Uint8List arrayify(String hexString) {
  hexString = hexString.replaceAll(RegExp(r'\s+'), '');
  List<int> bytes = [];
  for (int i = 0; i < hexString.length; i += 2) {
    String byteHex = hexString.substring(i, i + 2);
    int byteValue = int.parse(byteHex, radix: 16);
    bytes.add(byteValue);
  }
  return Uint8List.fromList(bytes);
}

/// Encrypts the provided public key bytes [publicKeyBytes] with EcdsaPublicKey.
///
/// - [publicKeyBytes]: The bytes of the public key.
///
/// Returns a [Future] that completes with a list of Uint8List representing the JSON Web Key [x] and [y].
/// Throws an exception if the public key is invalid.
Future<List<String>?> getPublicKeyFromBytes(Uint8List publicKeyBytes) async {
  final pKey =
      await EcdsaPublicKey.importSpkiKey(publicKeyBytes, EllipticCurve.p256);
  final jwk = await pKey.exportJsonWebKey();
  if (jwk.containsKey('x') && jwk.containsKey('y')) {
    final x = base64Url.normalize(jwk['x']);
    final y = base64Url.normalize(jwk['y']);

    final decodedX = hexlify(base64Url.decode(x));
    final decodedY = hexlify(base64Url.decode(y));

    return [decodedX, decodedY];
  } else {
    throw "Invalid public key";
  }
}

/// Converts the list of integer values [intArray] to a hexadecimal string.
///
/// - [intArray]: The list of integer values to convert.
///
/// Returns a hexadecimal string representation of the input list.
String hexlify(List<int> intArray) {
  var ss = <String>[];
  for (int value in intArray) {
    ss.add(value.toRadixString(16).padLeft(2, '0'));
  }
  return "0x${ss.join('')}";
}

/// Throws an exception with the provided [exception] message if the given [requirement] is not met.
///
/// - [requirement]: The condition to check.
/// - [exception]: The exception message to throw if the requirement is not met.
require(bool requirement, String exception) {
  if (!requirement) {
    throw Exception(exception);
  }
}

/// Computes the SHA-256 hash of the given input [input].
///
/// - [input]: The input bytes to hash.
///
/// Returns a [Digest] representing the SHA-256 hash.
Digest sha256Hash(List<int> input) {
  return sha256.convert(input);
}

/// Checks if the first byte in the provided [bytes] is 0x0 and the second byte's most significant bit is set.
///
/// - [bytes]: The list of bytes to check.
///
/// Returns true if the first byte is 0x0 and the second byte's most significant bit is set; otherwise, false.
bool shouldRemoveLeadingZero(Uint8List bytes) {
  return bytes[0] == 0x0 && (bytes[1] & (1 << 7)) != 0;
}

/// Concatenates a list of lists of integer values [buff] into a single list of integers.
///
/// - [buff]: The list of lists of integer values to concatenate.
///
/// Returns a list of integers representing the concatenated values.
List<int> toBuffer(List<List<int>> buff) {
  return List<int>.from(buff.expand((element) => element).toList());
}
