import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:passkeysafe/utils/passkeys.dart';
import 'package:uuid/uuid.dart';

String randomChallenge(PassKeysOptions options) {
  final uuid = const Uuid()
      .v5buffer(Uuid.NAMESPACE_URL, options.name, List<int>.filled(32, 0));
  return base64Url.encode(uuid);
}

Uint8List clientDataHash(PassKeysOptions options, {String? challenge}) {
  options.challenge = challenge ?? randomChallenge(options);
  final clientDataJson = jsonEncode({
    "type": options.type,
    "challenge": options.challenge,
    "origin": options.origin,
    "crossOrigin": options.crossOrigin
  });
  return Uint8List.fromList(utf8.encode(clientDataJson));
}
