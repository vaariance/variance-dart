part of 'package:variance_dart/variance.dart';

class AuthData {
  final String credentialHex;
  final String credentialId;
  final List<String> publicKey;
  final String aaGUID;
  AuthData(this.credentialHex, this.credentialId, this.publicKey, this.aaGUID);
}

class PassKeyPair with SecureStorageMixin {
  final Uint8List credentialHexBytes;
  final String credentialId;
  final List<Uint256> publicKey;
  final String name;
  final String aaGUID;
  final DateTime registrationTime;
  PassKeyPair(this.credentialHexBytes, this.credentialId, this.publicKey,
      this.name, this.aaGUID, this.registrationTime);

  factory PassKeyPair.fromJson(String source) =>
      PassKeyPair.fromMap(json.decode(source) as Map<String, dynamic>);

  factory PassKeyPair.fromMap(Map<String, dynamic> map) {
    return PassKeyPair(
      Uint8List.fromList(map['credentialHexBytes']),
      map['credentialId'],
      List<Uint256>.from(
        (map['publicKey'] as List<String>).map<Uint256>(
          (x) => Uint256.fromHex(x),
        ),
      ),
      map['name'],
      map['aaGUID'],
      DateTime.fromMillisecondsSinceEpoch(map['registrationTime']),
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'credentialHexBytes': credentialHexBytes.toList(),
      'credentialId': credentialId,
      'publicKey': publicKey.map((x) => x.toHex()).toList(),
      'name': name,
      'aaGUID': aaGUID,
      'registrationTime': registrationTime.millisecondsSinceEpoch,
    };
  }

  @override
  SecureStorageMiddleware withSecureStorage(SecureStorage secureStorage,
      {Authentication? authMiddleware}) {
    return SecureStorageMiddleware(
        secureStorage: secureStorage,
        authMiddleware: authMiddleware,
        credential: toJson());
  }

  static Future<PassKeyPair?> loadFromSecureStorage(
      {required SecureStorageRepository storageMiddleware,
      SSAuthOperationOptions? options}) {
    return storageMiddleware
        .readCredential(CredentialType.passkeypair, options: options)
        .then((value) => value != null ? PassKeyPair.fromJson(value) : null);
  }
}

class PassKeySignature {
  final String credentialId;
  final List<Uint256> rs;
  final Uint8List authData;
  final String clientDataPrefix;
  final String clientDataSuffix;
  PassKeySignature(this.credentialId, this.rs, this.authData,
      this.clientDataPrefix, this.clientDataSuffix);

  Uint8List toList() {
    return abi.encode([
      'uint256',
      'uint256',
      'bytes',
      'string',
      'string'
    ], [
      rs[0].value,
      rs[1].value,
      authData,
      clientDataPrefix,
      clientDataSuffix
    ]);
  }
}

class PassKeySigner implements PasskeyInterface {
  final _makeCredentialJson = '''{
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

  final _getAssertionJson = '''{
    "allowCredentialDescriptorList": [],
    "authenticatorExtensions": "",
    "clientDataHash": "",
    "requireUserPresence": true,
    "requireUserVerification": false,
    "rpId": ""
  }''';

  final PassKeysOptions _opts;

  final Authenticator _auth;

  String? _defaultId;

  PassKeySigner(String namespace, String name, String origin,
      {bool? crossOrigin})
      : _opts = PassKeysOptions(
          namespace: namespace,
          name: name,
          origin: origin,
          crossOrigin: crossOrigin ?? false,
        ),
        _auth = Authenticator(true, true);

  @override
  String? get defaultId => _defaultId;

  @override
  PassKeysOptions get opts => _opts;

  @override
  String dummySignature =
      "0xe017c9b829f0d550c9a0f1d791d460485b774c5e157d2eaabdf690cba2a62726b3e3a3c5022dc5301d272a752c05053941b1ca608bf6bc8ec7c71dfe15d5305900000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001600000000000000000000000000000000000000000000000000000000000000025205f5f63c4a6cebdc67844b75186367e6d2e4f19b976ab0affefb4e981c22435050000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000247b2274797065223a22776562617574686e2e676574222c226368616c6c656e6765223a2200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001d222c226f726967696e223a226170692e776562617574686e2e696f227d000000";

  @override
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

  @override
  Uint8List clientDataHash32(PassKeysOptions options, {String? challenge}) {
    final dataBuffer = clientDataHash(options, challenge: challenge);
    final hash = sha256Hash(dataBuffer);
    return Uint8List.fromList(hash.bytes);
  }

  @override
  String credentialIdToBytes32Hex(List<int> credentialId) {
    require(credentialId.length <= 32, "exception: credentialId too long");
    while (credentialId.length < 32) {
      credentialId.insert(0, 0);
    }
    return hexlify(credentialId);
  }

  @override
  String getAddress({int index = 0, bytes}) {
    return credentialIdToBytes32Hex(bytes);
  }

  @override
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

  @override
  Future<Uint8List> personalSign(Uint8List hash,
      {int? index, String? id}) async {
    require(id != null, "credential id expected");
    final signature = await signToPasskeySignature(hash, id!);
    return signature.toList();
  }

  @override
  Future<PassKeyPair> register(
      String name, bool requiresUserVerification) async {
    final attestation = await _register(name, requiresUserVerification);
    final authData = _decodeAttestation(attestation);
    if (authData.publicKey.length != 2) {
      throw "Invalid public key";
    }
    _defaultId = authData.credentialId;
    return PassKeyPair(
      hexToBytes(authData.credentialHex),
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

  @override
  Future<MsgSignature> signToEc(Uint8List hash,
      {int? index, String? id}) async {
    require(id != null, "credential id expected");
    final signature = await signToPasskeySignature(hash, id!);
    return MsgSignature(signature.rs[0].value, signature.rs[1].value, 0);
  }

  @override
  Future<PassKeySignature> signToPasskeySignature(
      Uint8List hash, String credentialId) async {
    final webAuthnOptions = _opts;
    webAuthnOptions.type = "webauthn.get";

    // Prepare hash
    final hashBase64 = base64Url
        .encode(hash)
        .replaceAll(RegExp(r'=', multiLine: true, caseSensitive: false), '');

    // Prepare challenge
    final challenge32 =
        clientDataHash32(webAuthnOptions, challenge: hashBase64);

    // Authenticate
    final assertion = await _authenticate([credentialId], challenge32, true);
    final sig = await getMessagingSignature(assertion.signature);

    // Prepare challenge for response
    final challenge = clientDataHash(webAuthnOptions, challenge: hashBase64);
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

  Future<Assertion> _authenticate(List<String> credentialIds,
      Uint8List challenge, bool requiresUserVerification) async {
    final entity = GetAssertionOptions.fromJson(jsonDecode(_getAssertionJson));
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

  AuthData _decodeAttestation(Attestation attestation) {
    final attestationAsCbor = attestation.asCBOR();
    final decodedAttestationAsCbor =
        cbor.decode(attestationAsCbor).toObject() as Map;
    final authData = decodedAttestationAsCbor["authData"];
    final decode = _decode(authData);
    return decode;
  }

  String _randomChallenge(PassKeysOptions options) {
    final uuid = const Uuid()
        .v5buffer(Uuid.NAMESPACE_URL, options.name, List<int>.filled(32, 0));
    return base64Url.encode(uuid);
  }

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

class PassKeysOptions {
  final String namespace;
  final String name;
  final String origin;
  bool? crossOrigin;
  String? challenge;
  String? type;
  PassKeysOptions(
      {required this.namespace,
      required this.name,
      required this.origin,
      this.crossOrigin,
      this.challenge,
      this.type});
}
