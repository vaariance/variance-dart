library pks_4337_sdk;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
// ignore: depend_on_referenced_packages
import 'package:cbor/cbor.dart';
import 'package:crypto/crypto.dart';
import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:uuid/uuid.dart';
import 'package:web3dart/crypto.dart';
import 'package:webauthn/webauthn.dart';

export 'passkey_types.dart';

/// Webauthn [PassKeys] 
class PassKey implements PasskeyInterface {
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

  final PassKeysOptions _opts;

  final Authenticator _auth;

  PassKey(String namespace, String name, String origin, {bool? crossOrigin})
      : _opts = PassKeysOptions(
          namespace: namespace,
          name: name,
          origin: origin,
          crossOrigin: crossOrigin ?? false,
        ),
        _auth = Authenticator(true, true);

  PassKeysOptions get opts => _opts;

  /// [clientDataHash] creates a client data hash
  /// - @param [options] is the options object
  /// -@param [challenge] is a random challenge
  /// returns a [Uint8List]
  Uint8List clientDataHash(PassKeysOptions options, {String? challenge}) {
    options.challenge = challenge ?? _randomChallenge(options);
    final clientDataJson = jsonEncode({
      "type": options.type,
      "challenge": options.challenge,
      "origin": options.origin,
      "crossOrigin": options.crossOrigin
    });
    return Uint8List.fromList(utf8.encode(clientDataJson));
  }

  ///[clientDataHash32] must return a 32 bytes value
  /// - @param [options] is the options object
  /// -@param [challenge] is a random challenge
  /// returns hash
  Uint8List clientDataHash32(PassKeysOptions options, {String? challenge}) {
    final dataBuffer = clientDataHash(options, challenge: challenge);

    /// Hashes client data using the sha256 hashing algorithm
    final sha256Hash = sha256.convert(dataBuffer);
    return Uint8List.fromList(sha256Hash.bytes);
  }

  /// converts the credentialId to an 32 bytes hex
  /// - @param required [credentialId] is the credentialId
  /// returns a 32 byte hex string
  String credentialIdToBytes32Hex(List<int> credentialId) {
    require(credentialId.length <= 32, "exception: credentialId too long");
    while (credentialId.length < 32) {
      credentialId.insert(0, 0);
    }
    return hexlify(credentialId);
  }

  ///The [getMessagingSignature] function takes in the [authResponseSignature] from passkeys auth
  ///It uses the [ASN1Parser] to parse the signature decoded from base64
  ///and checks for objects in the List using the [nextObject] stream from the [ASN1Parser]
  ///we then check for the elements by index
  ///Remove leading zeros using [shouldRemoveLeadingZero]
  ///and convert to hex using [hexlify]
  ///and return a list of [String] [r] and [s]
  /// - @param required [signatureBytes] is the base64 encoded signature
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

  /// Call the [register] function in your flutter app
  /// to register a user and return a [PassKeyPair] key pair
  /// - @param required [name] is the user name
  /// - @param required [requiresUserVerification] is true if user verification is required
  /// returns a [PassKeyPair]
  Future<PassKeyPair> register(
      String name, bool requiresUserVerification) async {
    final attestation = await _register(name, requiresUserVerification);
    final authData = _decodeAttestation(attestation);
    if (authData.publicKey.length != 2) {
      throw "Invalid public key";
    }
    return PassKeyPair(
      authData.credentialHex,
      authData.credentialId,
      [
        Uint256.fromHex(authData.publicKey[0]),
        Uint256.fromHex(authData.publicKey[1]),
      ],
      name,
      authData.aaGUID,
      DateTime.now(),
    );
  }

  /// [sign] Signs the intended request and returns the signedMessage
  /// - @param required [hash] is the hash of the intended request
  /// - @param required [credentialId] is the credential id
  /// returns a [PassKeySignature]
  @override
  Future<PassKeySignature> sign(String hash, String credentialId) async {
    final options = _opts;
    options.type = "webauthn.get";
    final hash32 = hash.length == 64 ? hash : hash.substring(2);
    final hashBase64 = base64Url
        .encode(arrayify(hash32))
        .replaceAll(RegExp(r'=', multiLine: true, caseSensitive: false), '');
    final challenge32 = clientDataHash32(options, challenge: hashBase64);
    final assertion = await _authenticate([credentialId], challenge32, true);
    final sig = await getMessagingSignature(assertion.signature);
    log("{signature: $assertion.signature}");
    final challenge = clientDataHash(options, challenge: hashBase64);
    final clientDataJSON = utf8.decode(challenge);
    int challengePos = clientDataJSON.indexOf(hashBase64);
    String challengePrefix = clientDataJSON.substring(0, challengePos);
    String challengeSuffix =
        clientDataJSON.substring(challengePos + hashBase64.length);
    return PassKeySignature(
      base64Url.encode(assertion.selectedCredentialId),
      [
        Uint256.fromHex(sig[0]),
        Uint256.fromHex(sig[1]),
      ],
      assertion.authenticatorData,
      challengePrefix,
      challengeSuffix,
    );
  }

  ///[_authenticate] authenticates a user and returns an [Assertion]
  ///- @param required [credentialIds] is the credential ids
  ///- @param required [challenge] is a random challenge as part of the auth process
  ///- @param required [requiresUserVerification] is true if user verification is required
  /// returns an [Assertion]
  Future<Assertion> _authenticate(List<String> credentialIds,
      Uint8List challenge, bool requiresUserVerification) async {
    final entity = GetAssertionOptions.fromJson(jsonDecode(getAssertionJson));
    log("credentialIds: $credentialIds");
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
    entity.requireUserPresence = !requiresUserVerification;
    return await _auth.getAssertion(entity);
  }

  /// [_decode] Decodes the raw authentication data to extract relevant authentication details
  /// - @param required [authData] is the raw authentication data received from the authentication process.
  /// returns an AuthData object containing decoded authentication details
  AuthData _decode(dynamic authData) {
    // Extract the length of the public key from the authentication data.
    final l = (authData[53] << 8) + authData[54];

    // Calculate the offset for the start of the public key data.
    final publicKeyOffset = 55 + l;

    // Extract the public key data from the authentication data.
    final pKey = authData.sublist(publicKeyOffset);

    // Extract the credential ID from the authentication data.
    final List<int> credentialId = authData.sublist(55, publicKeyOffset);

    // Extract and encode the aaGUID from the authentication data.
    final aaGUID = base64Url.encode(authData.sublist(37, 53));

    // Decode the CBOR-encoded public key and convert it to a map.
    final decodedPubKey = cbor.decode(pKey).toObject() as Map;

    // Calculate the hash of the credential ID.
    final credentialHex = credentialIdToBytes32Hex(credentialId);

    // Extract x and y coordinates from the decoded public key.
    final x = hexlify(decodedPubKey[-2]);
    final y = hexlify(decodedPubKey[-3]);

    return AuthData(
        credentialHex, base64Url.encode(credentialId), [x, y], aaGUID);
  }

  ///[_decodeAttestation] Decodes the attestation certificate data to extract relevant authentication details.
  /// - @param required [attestation] is the attestation certificate
  /// returns an [AuthData] object
  AuthData _decodeAttestation(Attestation attestation) {
    final attestationAsCbor = attestation.asCBOR();
    final decodedAttestationAsCbor =
        cbor.decode(attestationAsCbor).toObject() as Map;
    final authData = decodedAttestationAsCbor["authData"];
    final decode = _decode(authData);
    log("decoded: $decode");
    return decode;
  }

  ///Creates random values with [Uuid] to generate a challenge
  /// - @param required [options] is the options object
  /// returns a [String]
  String _randomChallenge(PassKeysOptions options) {
    final uuid = const Uuid()
        .v5buffer(Uuid.NAMESPACE_URL, options.name, List<int>.filled(32, 0));
    return base64Url.encode(uuid);
  }

  ///[_register] Internal function to register a user
  ///- @param required [name] is the user name
  ///- @param required [requiresUserVerification] is true if user verification is required
  /// returns a [Attestation]
  Future<Attestation> _register(
      String name, bool requiresUserVerification) async {
    final options = _opts;
    options.type = "webauthn.create";
    final hash = clientDataHash32(options);
    final entity =
        MakeCredentialOptions.fromJson(jsonDecode(_makeCredentialJson));
    entity.userEntity = UserEntity(
      id: Uint8List.fromList(utf8.encode(name)),
      displayName: name,
      name: name,
    );
    entity.clientDataHash = hash;
    entity.rpEntity.id = options.namespace;
    entity.rpEntity.name = options.name;
    entity.requireUserVerification = requiresUserVerification;
    entity.requireUserPresence = !requiresUserVerification;
    return await _auth.makeCredential(entity);
  }

  /// [credentialIdToBytes32Hex] converts a 32 byte credentialAddress hex to a base64 string
  /// - @param required [credentialId] is the credential hex
  static String credentialHexToBase64(String credentialHex) {
    // Remove the "0x" prefix if present.
    if (credentialHex.startsWith("0x")) {
      credentialHex = credentialHex.substring(2);
    }

    List<int> credentialId = hexToBytes(credentialHex);

    while (credentialId.isNotEmpty && credentialId[0] == 0) {
      credentialId.removeAt(0);
    }
    return base64Url.encode(credentialId);
  }
}
