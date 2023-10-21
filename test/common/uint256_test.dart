import 'package:flutter_test/flutter_test.dart';
import 'package:pks_4337_sdk/pks_4337_sdk.dart';

import 'package:web3dart/web3dart.dart';
// Replace with your actual package import

void main() {
  group('Uint256 Tests', () {
    test('Construction from Hex String', () {
      const hexValue = '0x487a9a304539440000';
      final uint256 = Uint256.fromHex(hexValue);
      expect(uint256.toHex(),
          '0x0000000000000000000000000000000000000000000000487a9a304539440000');
    });

    test('Construction from Wei', () {
      final weiValue = EtherAmount.inWei(BigInt.from(12345));
      final uint256 = Uint256.fromWei(weiValue);
      expect(uint256.toWei(), weiValue);
    });

    test('Zero Value', () {
      final zero = Uint256.zero;
      expect(zero.value, BigInt.zero);
    });

    test('Multiplication', () {
      final value1 = Uint256(BigInt.from(5));
      final value2 = Uint256(BigInt.from(3));
      final result = value1 * value2;
      expect(result.value, BigInt.from(15));
    });

    test('Addition', () {
      final value1 = Uint256(BigInt.from(5));
      final value2 = Uint256(BigInt.from(3));
      final result = value1 + value2;
      expect(result.value, BigInt.from(8));
    });

    test('Subtraction', () {
      final value1 = Uint256(BigInt.from(5));
      final value2 = Uint256(BigInt.from(3));
      final result = value1 - value2;
      expect(result.value, BigInt.from(2));
    });

    test('Conversion to Hex String', () {
      final uint256 = Uint256(BigInt.from(255));
      expect(uint256.toHex(),
          '0x00000000000000000000000000000000000000000000000000000000000000ff');
    });

    test('Conversion to Integer', () {
      final uint256 = Uint256(BigInt.from(123));
      expect(uint256.toInt(), 123);
    });

    test('Conversion to Wei', () {
      final uint256 = Uint256(BigInt.from(1000000));
      final weiValue = uint256.toWei();
      expect(weiValue.getInWei, BigInt.from(1000000));
    });
  });
}
