part of 'common.dart';

/// Abstract base class for handling Ethereum's Application Binary Interface (ABI).
///
/// The ABI is a data encoding scheme used in Ethereum for ABI encoding
/// and interaction with contracts within Ethereum.
// ignore: camel_case_types
class abi {
  abi._();

  /// Decodes a list of types and values.
  ///
  /// - [types]: A list of string types.
  /// - [value]: A [Uint8List] containing the ABI-encoded data.
  ///
  /// Returns a list of decoded values.
  static List<T> decode<T>(List<String> types, Uint8List value) {
    List<AbiType> abiTypes = [];
    for (String type in types) {
      var abiType = parseAbiType(type);
      abiTypes.add(abiType);
    }
    final parsedData = TupleType(abiTypes).decode(value.buffer, 0);
    return parsedData.data as List<T>;
  }

  /// Encodes a list of types and values.
  ///
  /// - [types]: A list of string types.
  /// - [values]: A list of dynamic values to be encoded.
  ///
  /// Returns a [Uint8List] containing the ABI-encoded types and values.
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
