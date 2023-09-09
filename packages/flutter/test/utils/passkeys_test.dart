import 'dart:convert';
import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:passkeysafe/utils/passkeys.dart';
import 'random_challenge.dart';

main() {
  test('A random challenge', () {
    final options = PassKeysOptions(
        namespace: 'namespace', name: 'test', origin: 'https://example.com');
    final challenge = randomChallenge(options);

    expect(challenge.length, equals(44));
    expect(base64Url.decode(challenge), isNotNull);
    expect(challenge.contains('='), isTrue);
  });

  test('Hash 32', () {
    final options = PassKeysOptions(
        namespace: 'namespace', name: 'test', origin: 'https://example.com');
    final hash = clientDataHash(options);

    expect(hash.lengthInBytes, equals(32));
  });
}
