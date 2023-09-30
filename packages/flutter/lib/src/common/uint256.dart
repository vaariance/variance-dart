import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class Uint256 {
  final BigInt _value;

  Uint256(BigInt value) : _value = value;

  ///create and return a Uint256 value from hex values
  factory Uint256.fromHex(String hex) {
    return Uint256(hexToInt(hex));
  }

  factory Uint256.fromWei(EtherAmount inWei) {
    return Uint256(inWei.getInWei);
  }

  BigInt get value => _value;

  String toHex() {
    final hexString = _value.toRadixString(16);
    return '0x${hexString.padLeft(64, '0')}'; // Ensure it's 256 bits
  }

  int toInt() {
    return _value.toInt();
  }

  @override
  String toString() {
    return toHex();
  }

  EtherAmount toWei() {
    return EtherAmount.fromBigInt(EtherUnit.wei, _value);
  }
}
