import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:webcrypto/webcrypto.dart';

/// Converts [hexString] to its [Uint8List] representation that can be used in solidity
/// - @param required [hexString] is the hex string
/// returns [Uint8List]
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

/// [getPublicKeyFromBytes]
/// Encrypts the [publicKey] with [EcdsaPublicKey]
/// - @param required [publicKeyBytes] is the bytes of the public key
///
/// returns a list of [Uint8List] jsonWebKey [x] and [y]
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

/// [hexlify] converts a list of int values to a hex string
/// - @param required [b] is the list of int values
/// returns [String]
String hexlify(List<int> b) {
  var ss = <String>[];
  for (int value in b) {
    ss.add(value.toRadixString(16).padLeft(2, '0'));
  }
  return "0x${ss.join('')}";
}

Digest sha256Hash(List<int> input) {
  return sha256.convert(input);
}

/// Solidity style require for checking if a condition is met
/// - @param required [requirement] is the condition
/// - @param required [exception] is the exception message
require(bool requirement, String exception) {
  if (!requirement) {
    throw Exception(exception);
  }
}

/// checks if the first byte is 0x0
/// - @param required [bytes] is the list of bytes
/// returns [bool]
bool shouldRemoveLeadingZero(Uint8List bytes) {
  return bytes[0] == 0x0 && (bytes[1] & (1 << 7)) != 0;
}

/// converts a list of bytes to a list of [int] value
/// - @param required [buff] is the list of int values
List<int> toBuffer(List<List<int>> buff) {
  return List<int>.from(buff.expand((element) => element).toList());
}
