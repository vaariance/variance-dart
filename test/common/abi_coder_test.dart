import 'package:flutter_test/flutter_test.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:pks_4337_sdk/pks_4337_sdk.dart';

void main() {
  group('ABI Tests', () {
    test('ABI Decode', () {
      final types = [
        'bool',
        'uint256',
        'bytes32',
        'address',
        'string',
      ];
      final encodedValue = hexToBytes(
          "0x000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000051234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef00000000000000000000000006450dee7fd2fb8e39061434babcfc05599a6fb800000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000046a6f686e00000000000000000000000000000000000000000000000000000000");
      final decodedValue = abi.decode(types, encodedValue);

      expect(decodedValue[0], true); // bool
      expect(decodedValue[1], BigInt.from(5)); // uint256
      expect(
          decodedValue[2],
          hexToBytes(
              '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef')); // bytes32
      expect(
          decodedValue[3],
          EthereumAddress.fromHex(
              '0x06450dee7fd2fb8e39061434babcfc05599a6fb8')); // address
      expect(decodedValue[4], 'john'); // string
    });

    test('ABI Encode', () {
      final types = [
        'bool',
        'uint256',
        'bytes32',
        'address',
        'string',
      ];
      final values = [
        true,
        BigInt.from(5),
        hexToBytes(
            '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'),
        EthereumAddress.fromHex('0x06450dee7fd2fb8e39061434babcfc05599a6fb8'),
        "john",
      ];
      final encodedValue = abi.encode(types, values);

      final hex0 = hexToBytes(
          "0x0000000000000000000000000000000000000000000000000000000000000001");
      final hex1 = hexToBytes(
          "0000000000000000000000000000000000000000000000000000000000000005");

      final hex2 = hexToBytes(
          "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef");

      final hex3 = hexToBytes(
          "00000000000000000000000006450dee7fd2fb8e39061434babcfc05599a6fb8");

      expect(encodedValue.sublist(0, 32), hex0);
      expect(encodedValue.sublist(32, 64), hex1);
      expect(encodedValue.sublist(64, 96), hex2);
      expect(encodedValue.sublist(96, 128), hex3);
    });
  });
}
