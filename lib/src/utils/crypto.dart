part of '../../utils.dart';

/// Converts a hex string to a 32bytes `Uint8List`.
///
/// Parameters:
/// - [hexString]: The input hex string.
///
/// Returns a Uint8List containing the converted bytes.
///
/// Example:
/// ```dart
/// final hexString = '0x1a2b3c';
/// final resultBytes = arrayify(hexString);
/// ```
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

/// Retrieves the X and Y components of an ECDSA public key from its bytes.
///
/// Parameters:
/// - [publicKeyBytes]: The bytes of the ECDSA public key.
///
/// Returns a Future containing a List of two strings representing the X and Y components of the public key.
///
/// Example:
/// ```dart
/// final publicKeyBytes = Uint8List.fromList([4, 1, 2, 3]); // Replace with actual public key bytes
/// final components = await getPublicKeyFromBytes(publicKeyBytes);
/// print(components); // Output: ['01', '02']
/// ```
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

/// Converts a list of integers to a hexadecimal string.
///
/// Parameters:
/// - [intArray]: The list of integers to be converted.
///
/// Returns a string representing the hexadecimal value.
///
/// Example:
/// ```dart
/// final intArray = [1, 15, 255];
/// final hexString = hexlify(intArray);
/// print(hexString); // Output: '0x01ff'
/// ```
String hexlify(List<int> intArray) {
  var ss = <String>[];
  for (int value in intArray) {
    ss.add(value.toRadixString(16).padLeft(2, '0'));
  }
  return "0x${ss.join('')}";
}

/// Throws an exception if the specified requirement is not met.
///
/// Parameters:
/// - [requirement]: The boolean requirement to be checked.
/// - [exception]: The exception message to be thrown if the requirement is not met.
///
/// Throws an exception with the specified message if the requirement is not met.
///
/// Example:
/// ```dart
/// final value = 42;
/// require(value > 0, "Value must be greater than 0");
/// print("Value is valid: $value");
/// ```
require(bool requirement, String exception) {
  if (!requirement) {
    throw Exception(exception);
  }
}

/// Computes the SHA-256 hash of the specified input.
///
/// Parameters:
/// - [input]: The list of integers representing the input data.
///
/// Returns a [Digest] object representing the SHA-256 hash.
///
/// Example:
/// ```dart
/// final data = utf8.encode("Hello, World!");
/// final hash = sha256Hash(data);
/// print("SHA-256 Hash: ${hash.toString()}");
/// ```
Digest sha256Hash(List<int> input) {
  return sha256.convert(input);
}

/// Checks whether the leading zero should be removed from the byte array.
///
/// Parameters:
/// - [bytes]: The list of integers representing the byte array.
///
/// Returns `true` if the leading zero should be removed, otherwise `false`.
///
/// Example:
/// ```dart
/// final byteData = Uint8List.fromList([0x00, 0x01, 0x02, 0x03]);
/// final removeZero = shouldRemoveLeadingZero(byteData);
/// print("Remove Leading Zero: $removeZero");
/// ```
bool shouldRemoveLeadingZero(Uint8List bytes) {
  return bytes[0] == 0x0 && (bytes[1] & (1 << 7)) != 0;
}

/// Combines multiple lists of integers into a single list.
///
/// Parameters:
/// - [buff]: List of lists of integers to be combined.
///
/// Returns a new list containing all the integers from the input lists.
///
/// Example:
/// ```dart
/// final list1 = [1, 2, 3];
/// final list2 = [4, 5, 6];
/// final combinedList = toBuffer([list1, list2]);
/// print("Combined List: $combinedList");
/// ```
List<int> toBuffer(List<List<int>> buff) {
  return List<int>.from(buff.expand((element) => element).toList());
}
