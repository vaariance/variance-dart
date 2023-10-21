import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/signer/passkey_types.dart';
import 'package:web3dart/crypto.dart';
import 'const.dart';

void main() {
  test('A random challenge', () {
    final options = PassKeysOptions(
        namespace: 'namespace', name: 'test', origin: 'https://example.com');
    final challenge = randomChallenge(options);

    expect(challenge.length, equals(44));
    expect(base64Url.decode(challenge), isNotNull);
    expect(challenge.contains('='), isTrue);
  });

  test('clientDataHash32 returns a valid sha256 hash of the client data', () {
    // Arrange
    final passkeyUtils = PassKey(
      'https://example.com',
      'Example',
      'https://example.com',
    );

    // Act
    final result = passkeyUtils.clientDataHash32(passkeyUtils.opts);

    // Assert
    final expectedHash =
        sha256.convert(passkeyUtils.clientDataHash(passkeyUtils.opts));
    expect(result, equals(expectedHash.bytes));
  });
  test(
      'getMessagingSignature returns a list of two hex strings representing r and s values',
      () async {
    // Arrange
    final passkeyUtils = PassKey(
      'https://example.com',
      'Example',
      'https://example.com',
    );

    // Act
    final result = await passkeyUtils.getMessagingSignature(uint8List);

    // Assert
    expect(result, hasLength(2));
    expect(() => result[0], returnsNormally);
    expect(() => result[1], returnsNormally);
    expect(result[0].length, lessThanOrEqualTo(66));
    expect(result[0].length, lessThanOrEqualTo(66));
  });

  test('Test hexlify function', () {
    final bytes1 = [0x12, 0x34, 0xAB, 0xCD];
    expect(hexlify(bytes1), equals("0x1234abcd"));
    final bytes2 = <int>[];
    expect(hexlify(bytes2), equals("0x"));
    final bytes3 = [0x05];
    expect(hexlify(bytes3), equals("0x05"));
  });

  test('Test hexToArrayBuffer function', () {
    // Test case 1: Convert a hexadecimal string to a Uint8List
    const hexString1 = "11c647709ce1d4ea50f658287694cd34";
    final result1 = arrayify(hexString1);
    final expectedBytes1 = Uint8List.fromList([
      0x11,
      0xc6,
      0x47,
      0x70,
      0x9c,
      0xe1,
      0xd4,
      0xea,
      0x50,
      0xf6,
      0x58,
      0x28,
      0x76,
      0x94,
      0xcd,
      0x34
    ]);
    expect(result1, orderedEquals(expectedBytes1));

    // Test case 2: Convert an empty hexadecimal string to an empty Uint8List
    const hexString2 = "";
    final result2 = arrayify(hexString2);
    final expectedBytes2 = Uint8List.fromList([]);
    expect(result2, orderedEquals(expectedBytes2));

    // Test case 3: Convert a single-byte hexadecimal string to a Uint8List
    const hexString3 = "05";
    final result3 = arrayify(hexString3);
    final expectedBytes3 = Uint8List.fromList([0x05]);
    expect(result3, orderedEquals(expectedBytes3));
  });

  test('Test hexToBytes function', () {
    const hexStr1 = "0x1234abcd";
    final result1 = hexToBytes(hexStr1);
    final expectedBytes1 = [0x12, 0x34, 0xAB, 0xCD];
    expect(result1, orderedEquals(expectedBytes1));

    const hexStr2 = "0x";
    final result2 = hexToBytes(hexStr2);
    final expectedBytes2 = [];
    expect(result2, orderedEquals(expectedBytes2));

    const hexStr3 = "0x05";
    final result3 = hexToBytes(hexStr3);
    final expectedBytes3 = [0x05];
    expect(result3, orderedEquals(expectedBytes3));
  });

  test('_decode decodes valid auth data', () {
    // Create a valid authentication data object.
    final authData = AuthData('credentialHash', 'credentialId',
        ['xCoordinate', 'yCoordinate'], 'aaGUID');

    // Encode the authentication data to bytes.
    final encodedAuthData = authData;

    // Decode the authentication data back to an object.
    final decodedAuthData = decode(encodedAuthData);

    // Verify that the decoded authentication data is equal to the original.
    expect(decodedAuthData, authData);
  });

  test('_decode throws an exception on invalid auth data', () {
    // Create invalid authentication data bytes.
    final invalidAuthData = Uint8List.fromList([1, 2, 3, 4, 5]);

    // Expect an exception to be thrown when decoding the invalid auth data.
    expect(() => decode(invalidAuthData), throwsException);
  });

  test('_get credential hex from base64 credential id', () {
    final passkeyUtils = PassKey(
      'https://example.com',
      'Example',
      'https://example.com',
    );

    // Extract the credential ID from the authentication data.
    final List<int> credentialId =
        base64Url.decode("EUQ8dgl3CB-p6SewjKsmj25ng2IfKkAQLYzFhube47w=");

    final credentialHash32 =
        passkeyUtils.credentialIdToBytes32Hex(credentialId);

    expect(credentialHash32,
        "0x11443c760977081fa9e927b08cab268f6e6783621f2a40102d8cc586e6dee3bc");
  });

  test('_get credential id base 64 from hex', () {
    const credentialHex =
        "0x11443c760977081fa9e927b08cab268f6e6783621f2a40102d8cc586e6dee3bc";

    final credentialId = PassKey.credentialHexToBase64(credentialHex);

    expect("EUQ8dgl3CB-p6SewjKsmj25ng2IfKkAQLYzFhube47w=", credentialId);
  });
}
