import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
// import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:webauthn/webauthn.dart';
import 'package:webcrypto/webcrypto.dart';
// ignore: depend_on_referenced_packages
import 'package:pointycastle/export.dart';
import 'package:cbor/cbor.dart';

class PasskeyUtils {
  final PassKeysOptions _opts;
  final Authenticator _auth;

  PasskeyUtils(String namespace, String name, String origin)
      : _opts = PassKeysOptions(
          namespace: namespace,
          name: name,
          origin: origin,
        ),
        _auth = Authenticator(true, true);

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

  static const getAssertionJson = '''{
    "allowCredentialDescriptorList": [],
    "authenticatorExtensions": "",
    "clientDataHash": "",
    "requireUserPresence": true,
    "requireUserVerification": false,
    "rpId": ""
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

  ///Creates random values with [Uuid] to generate the challenge
  Uint8List _randomChallenge(PassKeysOptions options) {
    final uuid = const Uuid()
        .v5buffer(Uuid.NAMESPACE_URL, options.name, List<int>.filled(32, 0));
    return Uint8List.fromList(uuid);
  }

  ///Creates the [clientDataHash]
  Uint8List clientDataHash(PassKeysOptions options, Uint8List? challenge) {
    options.challenge = challenge ?? _randomChallenge(options);
    final clientDataJson = jsonEncode({
      "challenge": options.challenge,
      "origin": options.origin,
      "type": options.type
    });
    final dataBuffer = utf8.encode(clientDataJson);
    // final sha256Hash = sha256.convert(dataBuffer);
    return Uint8List.fromList(dataBuffer);
  }



/// Decodes the raw authentication data to extract relevant authentication details.
///
/// Parameters:
/// - `authData`: Raw authentication data received from the authentication process.
///
/// Returns:
/// An AuthData object containing decoded authentication details.
  AuthData _decode(dynamic authData) {
  // Extract the length of the public key from the authentication data.
    final l = (authData[53] << 8) + authData[54];

  // Calculate the offset for the start of the public key data.
    final publicKeyOffset = 55 + l;

  // Extract the public key data from the authentication data.
    final pKey = authData.sublist(publicKeyOffset);

  // Extract the credential ID from the authentication data.
    final credentialId = authData.sublist(55, publicKeyOffset);

 // Extract and encode the aaGUID from the authentication data.
    final aaGUID = base64Url.encode(authData.sublist(37, 53));

 // Decode the CBOR-encoded public key and convert it to a map.
    final decodedPubKey = cbor.decode(pKey).toObject() as Map;

// Calculate the hash of the credential ID.
    final credentialHash = hexlify(keccak256(Uint8List.fromList(credentialId)));
// Extract x and y coordinates from the decoded public key.
    final x = hexlify(decodedPubKey[-2]);
    final y = hexlify(decodedPubKey[-3]);

    return AuthData(
        credentialHash, base64Url.encode(credentialId), [x, y], aaGUID);
  }

  AuthData _decodeAttestation(Attestation attestation) {
    final attestationAsCbor = attestation.asCBOR();
    final decodedAttestationAsCbor =
        cbor.decode(attestationAsCbor).toObject() as Map;
    final authData = decodedAttestationAsCbor["authData"];
    return _decode(authData);
  }

  ///The register function registers a username and returns an [Attestation].
  ///
  ///The [Authenticator] allows for enables biometric authentication.
  ///
  ///See https://pub.dev/packages/webauthn
  Future<Attestation> _register(
      String name, bool requiresUserVerification) async {
    final options = _opts;
    options.type = "webauthn.create";
    final hash = clientDataHash(options, null);
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
    entity.requireUserVerification = requiresUserVerification;
    return await _auth.makeCredential(entity);
  }

  Future<Assertion> _authenticate(List<String> credentialIds,
      Uint8List challenge, bool requiresUserVerification) async {
    final entity = GetAssertionOptions.fromJson(jsonDecode(getAssertionJson));
    entity.allowCredentialDescriptorList = credentialIds
        .map((credentialId) => PublicKeyCredentialDescriptor(
            type: PublicKeyCredentialType.publicKey,
            id: base64Url.decode(credentialId)))
        .toList();
    if (entity.allowCredentialDescriptorList!.isEmpty) {
      throw AuthenticatorException('User not found');
    }
    entity.clientDataHash = challenge;
    entity.rpId = _opts.namespace;
    entity.requireUserVerification = requiresUserVerification;
    return await _auth.getAssertion(entity);
  }

  Future<PassKeyPair> register(
      String name, bool requiresUserVerification) async {
    final attestation = await _register(name, requiresUserVerification);
    final authData = _decodeAttestation(attestation);
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

  Future<PassKeySignature> signMessage(String hash, String credentialId) async {
    final challenge = Uint8List.fromList(utf8.encode(hash));
    final assertion = await _authenticate([credentialId], challenge, true);
    final sig = await getMessagingSignature(assertion.signature);
    // todo: verify the clientDataJson;
    final clientDataJSON = utf8.decode(clientDataHash(_opts, challenge));
    int challengePos = clientDataJSON.indexOf(base64Url.encode(challenge));
    String challengePrefix = clientDataJSON.substring(0, challengePos);
    String challengeSuffix =
        clientDataJSON.substring(challengePos + challenge.length);
    return PassKeySignature(
      base64Url.encode(assertion.selectedCredentialId),
      sig[0],
      sig[1],
      assertion.authenticatorData,
      challengePrefix,
      challengeSuffix,
    );
  }

// Retrieves a PassKeyPair for the given list of credential IDs.
/// This method follows a WebAuthn process to authenticate and retrieve the keys.
/// It returns a PassKeyPair containing various authentication details.
///
/// Parameters:
/// - `credentialIds`: A list of credential IDs to attempt authentication with.
///
/// Returns:
/// A Future containing a PassKeyPair object representing the retrieved authentication details.
  Future<PassKeyPair> getPassKeyPair(List<String> credentialIds) async {
    final options = _opts;
    options.type = "webauthn.get";
    final hash = clientDataHash(options, null);
    final assertion = await _authenticate(credentialIds, hash, true);
    final authData = _decode(assertion.authenticatorData);
    return PassKeyPair(
      authData.credentialHash,
      authData.credentialId,
      authData.publicKey[0],
      authData.publicKey[1],
      base64Url.encode(assertion.selectedCredentialUserHandle),
      authData.aaGUID,
      DateTime.now(),
    );
  }
}

class PassKeysOptions {
  final String namespace;
  final String name;
  final String origin;
  Uint8List? challenge;
  String? type;
  PassKeysOptions(
      {required this.namespace,
      required this.name,
      required this.origin,
      this.challenge,
      this.type});
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

class PassKeySignature {
  final String credentialId;
  final String r;
  final String s;
  final Uint8List authData;
  final String clientDataPrefix;
  final String clientDataSuffix;
  PassKeySignature(this.credentialId, this.r, this.s, this.authData,
      this.clientDataPrefix, this.clientDataSuffix);
}
