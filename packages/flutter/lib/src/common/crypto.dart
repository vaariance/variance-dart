import 'dart:convert';
import 'dart:typed_data';

// ignore: depend_on_referenced_packages
import 'package:pointycastle/export.dart';
import 'package:webcrypto/webcrypto.dart';

List<int> toBuffer(List<List<int>> buff) {
  return List<int>.from(buff.expand((element) => element).toList());
}

bool shouldRemoveLeadingZero(Uint8List bytes) {
  return bytes[0] == 0x0 && (bytes[1] & (1 << 7)) != 0;
}

///Converts base64 String to hex
String hexlify(List<int> b) {
  var ss = <String>[];
  for (int value in b) {
    ss.add(value.toRadixString(16).padLeft(2, '0'));
  }
  return "0x${ss.join('')}";
}

Uint8List keccak256(Uint8List input) {
  final digest = KeccakDigest(256);
  return digest.process(input);
}

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

///class takes in the [publicKey]
///Encrypts the [publicKey] with [EcdsaPublicKey] and returns a [JWK]
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

require(bool requirement, String exception) {
  if (!requirement) {
    throw Exception(exception);
  }
}
