part of 'common.dart';

class Uint256 implements Uint256Base {
  final BigInt _value;

  Uint256(this._value);

  factory Uint256.fromHex(String hex) {
    return Uint256(hexToInt(hex));
  }

  factory Uint256.fromWei(EtherAmount inWei) {
    return Uint256(inWei.getInWei);
  }

  @override
  BigInt get value => _value;

  static Uint256 get zero => Uint256(BigInt.zero);

  @override
  Uint256 operator *(Uint256 other) {
    return Uint256(_value * other._value);
  }

  @override
  Uint256 operator +(Uint256 other) {
    return Uint256(_value + other._value);
  }

  @override
  Uint256 operator -(Uint256 other) {
    return Uint256(_value - other._value);
  }

  @override
  Uint256 operator /(Uint256 other) {
    return Uint256(BigInt.from(_value / other._value));
  }

  @override
  String toHex() {
    final hexString = _value.toRadixString(16);
    return '0x${hexString.padLeft(64, '0')}';
  }

  @override
  int toInt() {
    return _value.toInt();
  }

  @override
  String toString() {
    return toHex();
  }

  @override
  EtherAmount toWei() {
    return EtherAmount.fromBigInt(EtherUnit.wei, _value);
  }
}
