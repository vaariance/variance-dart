part of 'interfaces.dart';

/// Abstract base class representing a 64-bit length big number, similar to Solidity.
///
/// This interface defines methods and properties for working with 64-bit length big numbers,
/// with operations such as multiplication, addition, subtraction, division, and various conversions.
abstract class Uint256Base {
  BigInt get value;

  Uint256Base operator *(covariant Uint256Base other);

  Uint256Base operator +(covariant Uint256Base other);

  Uint256Base operator -(covariant Uint256Base other);

  Uint256Base operator /(covariant Uint256Base other);

  /// Converts the value of this [Uint256] instance to a [BigInt] representing the equivalent amount in ether.
  ///
  /// Example 1:
  /// ```dart
  /// final value = Uint256(BigInt.from(5000000000));
  /// final etherValue = value.toEther(); // Converts the value to ether (0.000000000000000005)
  /// ```

  /// Example 2:
  /// ```dart
  /// final value = Uint256(BigInt.from(1000000000000000000));
  /// final etherValue = value.toEther(); // Converts the value to ether (1.0)
  /// ```
  BigInt toEther();

  /// Converts the value of this [Uint256] instance to an [EtherAmount] with the equivalent amount in wei.
  ///
  /// Example 1:
  /// ```dart
  /// final value = Uint256(BigInt.from(5000000000));
  /// final etherAmount = value.toEtherAmount(); // Converts the value to EtherAmount (5 wei)
  /// ```

  /// Example 2:
  /// ```dart
  /// final value = Uint256(BigInt.from(1000000000000000000));
  /// final etherAmount = value.toEtherAmount(); // Converts the value to EtherAmount (1 ether)
  /// ```
  EtherAmount toEtherAmount();

  /// Converts the value of this [Uint256] instance to a hexadecimal string with a length of 64 characters, padded with leading zeros.
  ///
  /// Example 1:
  /// ```dart
  /// final value = Uint256(BigInt.from(42));
  /// final hexString = value.toHex(); // Converts the value to hex (0x000000000000000000000000000000000000000000000000000000000000002a)
  /// ```

  /// Example 2:
  /// ```dart
  /// final value = Uint256(BigInt.from(255));
  /// final hexString = value.toHex(); // Converts the value to hex (0x00000000000000000000000000000000000000000000000000000000000000ff)
  /// ```
  String toHex();

  /// Converts the value of this [Uint256] instance to an integer.
  ///
  /// Example 1:
  /// ```dart
  /// final value = Uint256(BigInt.from(42));
  /// final intValue = value.toInt(); // Converts the value to an integer (42)
  /// ```

  /// Example 2:
  /// ```dart
  /// final value = Uint256(BigInt.from(123456789));
  /// final intValue = value.toInt(); // Converts the value to an integer (123456789)
  /// ```
  int toInt();

  /// Returns the hexadecimal representation of this [Uint256] instance as a string.
  ///
  /// Example 1:
  /// ```dart
  /// final value = Uint256(BigInt.from(42));
  /// final stringValue = value.toString(); // Converts the value to a string (0x000000000000000000000000000000000000000000000000000000000000002a)
  /// ```

  /// Example 2:
  /// ```dart
  /// final value = Uint256(BigInt.from(255));
  /// final stringValue = value.toString(); // Converts the value to a string (0x00000000000000000000000000000000000000000000000000000000000000ff)
  /// ```
  @override
  String toString();

  /// Converts the value of this [Uint256] instance to a [BigInt] with a scale defined by [decimals].
  ///
  /// Example 1:
  /// ```dart
  /// final value = Uint256(BigInt.from(42));
  /// final unitValue = value.toUnit(3); // Converts the value to a unit with 3 decimals (42000)
  /// ```

  /// Example 2:
  /// ```dart
  /// final value = Uint256(BigInt.from(123456789));
  /// final unitValue = value.toUnit(6); // Converts the value to a unit with 6 decimals (123456789000000)
  /// ```
  BigInt toUnit(int decimals);

  /// Converts the value of this [Uint256] instance from a unit with [decimals] to a double.
  ///
  /// Example 1:
  /// ```dart
  /// final value = Uint256(BigInt.from(42000));
  /// final doubleValue = value.fromUnit(3); // Converts the value from a unit with 3 decimals to a double (42.0)
  /// ```

  /// Example 2:
  /// ```dart
  /// final value = Uint256(BigInt.from(123456789000000));
  /// final doubleValue = value.fromUnit(6); // Converts the value from a unit with 6 decimals to a double (123.456789)
  /// ```
  double fromUnit(int decimals);

  /// Converts the value of this [Uint256] instance to a [BigInt] representing the equivalent amount in wei.
  ///
  /// Example 1:
  /// ```dart
  /// final value = Uint256(BigInt.from(5000000000));
  /// final weiValue = value.toWei(); // Converts the value to wei (5000000000)
  /// ```

  /// Example 2:
  /// ```dart
  /// final value = Uint256(BigInt.from(1000000000000000000));
  /// final weiValue = value.toWei(); // Converts the value to wei (1000000000000000000)
  /// ```
  BigInt toWei();
}
