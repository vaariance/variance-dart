part of 'common.dart';

class Uint256 implements Uint256Base {
  static Uint256 get zero => Uint256(BigInt.zero);

  final BigInt _value;

  const Uint256(this._value);

  /// Creates a [Uint256] instance from a hexadecimal string [hex].
  ///
  /// Example:
  /// ```dart
  /// final value = Uint256.fromHex('0x1a'); // Creates Uint256 with value 26
  /// ```
  factory Uint256.fromHex(String hex) {
    return Uint256(hexToInt(hex));
  }

  /// Creates a [Uint256] instance from an [EtherAmount] value [inWei].
  ///
  /// Example:
  /// ```dart
  /// final amount = EtherAmount.inWei(BigInt.from(5)).getInWei;
  /// final value = Uint256.fromWei(amount); // Creates Uint256 with value 5
  /// ```
  factory Uint256.fromWei(EtherAmount inWei) {
    return Uint256(inWei.getInWei);
  }

  /// Creates a [Uint256] instance from an integer value [value].
  ///
  /// Example:
  /// ```dart
  /// final value = Uint256.fromInt(42); // Creates Uint256 with value 42
  /// ```
  factory Uint256.fromInt(int value) {
    return Uint256(BigInt.from(value));
  }

  /// Creates a [Uint256] instance from a string representation of a number [value].
  ///
  /// Example:
  /// ```dart
  /// final value = Uint256.fromString('123'); // Creates Uint256 with value 123
  /// ```
  factory Uint256.fromString(String value) {
    return Uint256(BigInt.parse(value));
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
  BigInt toUnit(int decimals) {
    return _value * BigInt.from(pow(10, decimals));
  }

  @override
  double fromUnit(int decimals) {
    return _value / BigInt.from(pow(10, decimals));
  }

  @override
  BigInt toWei() {
    return toEtherAmount().getInWei;
  }
}
