import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class Uint256 {
  final BigInt _value;

  Uint256(BigInt value) : _value = value;

  BigInt get value => _value;

  ///create and return a Uint256 value from hex values
  factory Uint256.fromHex(String hex) {
    final bigIntValue = BigInt.parse(strip0x(hex), radix: 16);
    return Uint256(bigIntValue);
  }

  factory Uint256.fromWei(EtherAmount inWei) {
    return Uint256(inWei.getInWei);
  }

  EtherAmount toWei() {
    return EtherAmount.fromBigInt(EtherUnit.wei, _value);
  }

  String toHex() {
    final hexString = _value.toRadixString(16);
    return '0x${hexString.padLeft(64, '0')}'; // Ensure it's 256 bits
  }

  @override
  String toString() {
    return toHex();
  }

  int toInt() {
    return _value.toInt();
  }
}
