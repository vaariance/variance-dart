// ignore_for_file: file_names

import 'dart:typed_data';

// ignore: implementation_imports
import 'package:web3dart/src/utils/length_tracking_byte_sink.dart';

import 'package:eth_sig_util/util/abi.dart';
import 'package:web3dart/web3dart.dart';

// ignore: camel_case_types
class abi {
  abi._();
  static encode<T>(List<String> types, List<dynamic> values) {
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

  static List<T> decode<T>(List<String> types, Uint8List value) {
    List<AbiType> abiTypes = [];
    for (String type in types) {
      var abiType = parseAbiType(type);
      abiTypes.add(abiType);
    }
    final parsedData = TupleType(abiTypes).decode(value.buffer, 0);
    return parsedData.data as List<T>;
  }

  static Uint8List encodePacked<T>(List<String> types, List<dynamic> values) {
    return AbiUtil.solidityPack(types, values);
  }
}
