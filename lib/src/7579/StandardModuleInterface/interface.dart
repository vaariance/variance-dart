import 'dart:typed_data';

import 'package:variance_dart/variance_dart.dart';
import 'package:web3dart/web3dart.dart';

part 'executors.dart';
part 'hooks.dart';
part 'validators.dart';

abstract interface class Base7579ModuleInterface {
  String get name;

  String get version;

  ModuleType get type;

  EthereumAddress get address;

  Uint8List? get initData;

  bool isInitialized();

  bool isModuleType(ModuleType type);
}
