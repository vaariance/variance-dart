import 'dart:convert';
import 'dart:typed_data';
import 'package:asn1lib/asn1lib.dart';
import 'package:webcrypto/webcrypto.dart';
// ignore: depend_on_referenced_packages
import 'package:pointycastle/export.dart';

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

Uint8List hexToArrayBuffer(String hexString) {
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

Future<List<String>> getMessagingSignature(Uint8List signatureBytes) async {
    ASN1Parser parser = ASN1Parser(signatureBytes);
    ASN1Sequence parsedSignature = parser.nextObject() as ASN1Sequence;
    ASN1Integer rValue = parsedSignature.elements[0] as ASN1Integer;
    ASN1Integer sValue = parsedSignature.elements[1] as ASN1Integer;
    Uint8List rBytes = rValue.valueBytes();
    Uint8List sBytes = sValue.valueBytes();

    if (shouldRemoveLeadingZero(rBytes)) {
      rBytes = rBytes.sublist(1);
    }
    if (shouldRemoveLeadingZero(sBytes)) {
      sBytes = sBytes.sublist(1);
    }

    final r = hexlify(rBytes);
    final s = hexlify(sBytes);
    return [r, s];
  }

  // Future<Transaction> signWithPrivateKey(
  //     Uint8List privateKey, Uint8List messageHash) {
  //   final ECDomainParameters params = ECCurve_secp256k1();
  //   final digest = SHA256Digest();
  //   final signer = ECDSASigner(null, HMac(digest, 64));
  //   final key = ECPrivateKey(bytesToUnsignedInt(privateKey), params);
  //   signer.init(true, PrivateKeyParameter(key));
  //   var sig = signer.generateSignature(messageHash) as ECSignature;
      
  //   return sig.r;
  // }
