part of 'common.dart';

class Uint256 implements Uint256Base {
  static Uint256 get zero => Uint256(BigInt.zero);

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
  BigInt toEther() {
    return toEtherAmount().getInEther;
  }

  @override
  EtherAmount toEtherAmount() {
    return EtherAmount.fromBigInt(EtherUnit.wei, _value);
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
  double toUnit(int decimals) {
    return _value / BigInt.from(pow(10, decimals));
  }

  @override
  BigInt toWei() {
    return toEtherAmount().getInWei;
  }
}
