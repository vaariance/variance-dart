import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:webauthn/webauthn.dart';
import 'package:webcrypto/webcrypto.dart';
import 'package:pointycastle/export.dart';
import 'package:cbor/cbor.dart';

class PasskeyUtils {
  late PassKeysOptions _opts;

  PasskeyUtils(String namespace, String name, String origin) {
    _opts = PassKeysOptions(
      namespace: namespace,
      name: name,
      origin: origin,
      challenge: '',
      type: '',
    );
  }

  static const _makeCredentialJson = '''{
    "authenticatorExtensions": "",
    "clientDataHash": "",
    "credTypesAndPubKeyAlgs": [
        ["public-key", -7]
    ],
    "excludeCredentials": [],
    "requireResidentKey": true,
    "requireUserPresence": true,
    "requireUserVerification": false,
    "rp": {
        "name": "",
        "id": ""
    },
    "user": {
        "name": "",
        "displayName": "",
        "id": ""
    }
  }''';

  bool shouldRemoveLeadingZero(Uint8List bytes) {
    return bytes[0] == 0x0 && (bytes[1] & (1 << 7)) != 0;
  }

  List<int> toBuffer(List<List<int>> buff) {
    return List<int>.from(buff.expand((element) => element).toList());
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

  ///The [getMessagingSignature] function takes in the [authResponseSignature] from passkeys auth
  ///It uses the [ASN1Parser] to parse the signature decoded from base64
  ///and checks for objects in the List using the [nextObject] stream from the [ASN1Parser]
  ///we then check for the elements by index
  ///Remove leading zeros using [shouldRemoveLeadingZero]
  ///and convert to hex using [hexlify]
  ///and return [r] and [s]

  Future<List<String>?> getMessagingSignature(
      String authResponseSignature) async {
    Uint8List signatureBytes = base64Url.decode(authResponseSignature);

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

  ///Creates random values with [Uuid] to generate the challenge
  String _randomChallenge(PassKeysOptions options) {
    final uuid = Uuid()
        .v5buffer(Uuid.NAMESPACE_URL, options.name, List<int>.filled(32, 0));
    final base64EncodedUuid = base64Url.encode(uuid);
    return base64EncodedUuid;
  }

  ///Creates the [clientDataHash]
  Uint8List clientDataHash(PassKeysOptions options) {
    options.challenge = _randomChallenge(options);
    final clientDataJson = jsonEncode({
      "challenge": options.challenge,
      "origin": options.origin,
      "type": options.type
    });
    final dataBuffer = utf8.encode(clientDataJson);
    final sha256Hash = sha256.convert(dataBuffer);
    return Uint8List.fromList(sha256Hash.bytes);
  }

  AuthData _decode(Attestation attestation) {
    final attestationAsCbor = attestation.asCBOR();
    final decodedAttestationAsCbor =
        cbor.decode(attestationAsCbor).toObject() as Map;
    final authData = decodedAttestationAsCbor["authData"];

    final l = (authData[53] << 8) + authData[54];
    final publicKeyOffset = 55 + l;

    final pKey = authData.sublist(publicKeyOffset);
    final credentialId = authData.sublist(55, publicKeyOffset);
    final aaGUID = base64Url.encode(authData.sublist(37, 53));
    final decodedPubKey = cbor.decode(pKey).toObject() as Map;
    final credentialHash = hexlify(keccak256(Uint8List.fromList(credentialId)));

    final x = hexlify(decodedPubKey[-2]);
    final y = hexlify(decodedPubKey[-3]);

    return AuthData(
        credentialHash, base64Url.encode(credentialId), [x, y], aaGUID);
  }

  ///The register function registers a username and returns an [Attestation]
  ///The [Authenticator] allows for enables biometric authentication.
  ///https://pub.dev/packages/webauthn
  Future<Attestation> _register(String name) async {
    final auth = Authenticator(true, false);
    final options = _opts;
    options.type = "webauthn.create";
    final hash = clientDataHash(options);
    final entity =
        MakeCredentialOptions.fromJson(jsonDecode(_makeCredentialJson));
    entity.userEntity = UserEntity(
      id: Uint8List.fromList(name.codeUnits),
      displayName: name,
      name: name,
    );
    entity.clientDataHash = hash;
    entity.rpEntity.id = options.namespace;
    entity.rpEntity.name = options.name;
    return await auth.makeCredential(entity);
  }

  Future<PassKeyPair> register(String name) async {
    final attestation = await _register(name);

    final authData = _decode(attestation);

    if (authData.publicKey.length != 2) {
      throw "Invalid public key";
    }
    return PassKeyPair(
      authData.credentialHash,
      authData.credentialId,
      authData.publicKey[0],
      authData.publicKey[1],
      name,
      authData.aaGUID,
      DateTime.now(),
    );
  }
}

class PassKeysOptions {
  final String namespace;
  final String name;
  final String origin;
  String? challenge;
  String? type;
  PassKeysOptions(
      {required this.namespace,
      required this.name,
      required this.origin,
      this.challenge,
      this.type});
}

class CredentialData {
  final String username;
  final Attestation attestation;

  CredentialData(this.username, this.attestation);
}

class AuthData {
  final String credentialHash;
  final String credentialId;
  final List<String> publicKey;
  final String aaGUID;
  AuthData(this.credentialHash, this.credentialId, this.publicKey, this.aaGUID);
}

class PassKeyPair {
  final String credentialHash;
  final String? pubKeyX;
  final String? pubKeyY;
  final String credentialId;
  final String name;
  final String aaGUID;
  final DateTime registrationTime;
  PassKeyPair(this.credentialHash, this.credentialId, this.pubKeyX,
      this.pubKeyY, this.name, this.aaGUID, this.registrationTime);
}
