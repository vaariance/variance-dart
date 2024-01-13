part of 'common.dart';

/// Abstract base class for handling Ethereum's Application Binary Interface (ABI).
///
/// The ABI is a data encoding scheme used in Ethereum for ABI encoding
/// and interaction with contracts within Ethereum.
// ignore: camel_case_types
class abi {
  abi._();

  /// Decodes a list of ABI-encoded types and values.
  ///
  /// Parameters:
  ///   - `types`: A list of string types describing the ABI types to decode.
  ///   - `value`: A [Uint8List] containing the ABI-encoded data to be decoded.
  ///
  /// Returns:
  ///   A list of decoded values with the specified type.
  ///
  /// Example:
  /// ```dart
  /// var decodedValues = abi.decode(['uint256', 'string'], encodedData);
  /// ```
  static List decode(List<String> types, Uint8List value) {
    List<AbiType> abiTypes = [];
    for (String type in types) {
      var abiType = parseAbiType(type);
      abiTypes.add(abiType);
    }
    final parsedData = TupleType(abiTypes).decode(value.buffer, 0);
    return parsedData.data;
  }

  /// Encodes a list of types and values into ABI-encoded data.
  ///
  /// Parameters:
  ///   - `types`: A list of string types describing the ABI types.
  ///   - `values`: A list of dynamic values to be ABI-encoded.
  ///
  /// Returns:
  ///   A [Uint8List] containing the ABI-encoded types and values.
  ///
  /// Example:
  /// ```dart
  /// var encodedData = abi.encode(['uint256', 'string'], [BigInt.from(123), 'Hello']);
  /// ```
  static Uint8List encode(List<String> types, List<dynamic> values) {
    List<AbiType> abiTypes = [];
    LengthTrackingByteSink result = LengthTrackingByteSink();
    for (String type in types) {
      var abiType = parseAbiType(type);
      abiTypes.add(abiType);
    }
    TupleType(abiTypes).encode(values, result);
    var resultBytes = result.asBytes();
    result.close();
    return resultBytes;
  }
}
