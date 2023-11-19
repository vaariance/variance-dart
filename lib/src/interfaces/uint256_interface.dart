part of '../../interfaces.dart';

/// Abstract base class representing a 64-bit length big number, similar to Solidity.
///
/// This interface defines methods and properties for working with 64-bit length big numbers,
/// with operations such as multiplication, addition, subtraction, division, and various conversions.
abstract class Uint256Base {
  /// The value of the Uint256.
  BigInt get value;

  /// Multiplies this Uint256 by [other].
  ///
  /// - [other]: The Uint256 to multiply with.
  ///
  /// Returns a new Uint256 representing the result of the multiplication.
  Uint256Base operator *(covariant Uint256Base other);

  /// Adds [other] to this Uint256.
  ///
  /// - [other]: The Uint256 to add.
  ///
  /// Returns a new Uint256 representing the result of the addition.
  Uint256Base operator +(covariant Uint256Base other);

  /// Subtracts [other] from this Uint256.
  ///
  /// - [other]: The Uint256 to subtract.
  ///
  /// Returns a new Uint256 representing the result of the subtraction.
  Uint256Base operator -(covariant Uint256Base other);

  /// Divides this Uint256 by [other].
  ///
  /// - [other]: The Uint256 to divide by.
  ///
  /// Returns a new Uint256 representing the result of the division.
  Uint256Base operator /(covariant Uint256Base other);

  /// Converts this Uint256 to an [EtherAmount] in ether.
  ///
  /// Returns an [BigInt] representing the Uint256 value in ether.
  BigInt toEther();

  /// Converts this Uint256 to an [EtherAmount] in wei.
  ///
  /// Returns an [EtherAmount]
  EtherAmount toEtherAmount();

  /// Converts this Uint256 to a hexadecimal string.
  ///
  /// Returns a string representation of the Uint256 value in hexadecimal format.
  String toHex();

  /// Converts this Uint256 to an integer.
  ///
  /// Returns an integer representation of the Uint256 value.
  int toInt();

  /// Converts this Uint256 to a string.
  ///
  /// Returns a string representation of the Uint256 value.
  @override
  String toString();

  /// Converts this Uint256 to a [double] giving the [decimals].
  ///
  /// Returns an [double]
  double toUnit(int decimals);

  /// Converts this Uint256 to an [EtherAmount] in wei.
  ///
  /// Returns an [BigInt] representing the Uint256 value in wei.
  BigInt toWei();
}
