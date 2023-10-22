// ignore_for_file: file_names

import 'dart:typed_data';

import 'package:web3dart/web3dart.dart';

// ignore: camel_case_types

/// Class to handle Ethereum's Application Binary Interface (ABI).
///
/// The ABI is a data encoding scheme used in Ethereum for abi encoding
/// and interaction with contracts within Ethereum. This class provides methods
/// to encode and decode data in accordance with the ABI specification.
class abi {
  ///Not intended to be instantiated
  abi._();

  /// [decode] decodes a list of types and values
  /// - @param required types is a list of string types
  /// - @param required values is a list of dynamic values
  /// 
  /// returns a list of decoded value and types
  static List<T> decode<T>(List<String> types, Uint8List value) {
    List<AbiType> abiTypes = [];
    for (String type in types) {
      var abiType = parseAbiType(type);
      abiTypes.add(abiType);
    }
    final parsedData = TupleType(abiTypes).decode(value.buffer, 0);
    return parsedData.data as List<T>;
  }

  /// [encode] encodes a list of types and values
  /// - @param required types is a list of string types
  /// - @param required values is a list of dynamic values
  /// 
  /// returns a [Uint8List] containing the ABI encoded types and values.
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
