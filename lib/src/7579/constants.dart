part of '../../variance_dart.dart';

const int MODULE_TYPE_VALIDATOR = 1;
const int MODULE_TYPE_EXECUTOR = 2;
const int MODULE_TYPE_FALLBACK = 3;
const int MODULE_TYPE_HOOK = 4;

class ModuleInit<T1 extends EthereumAddress, T2 extends Uint8List> {
  final T1 module;
  final T2 initData;

  ModuleInit(this.module, this.initData);
}
