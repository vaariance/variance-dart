part of '../../variance_dart.dart';

final EthereumAddress SENTINEL_ADDRESS = EthereumAddress.fromHex(
  "0x0000000000000000000000000000000000000001",
);

const int MODULE_TYPE_VALIDATOR = 1;
const int MODULE_TYPE_EXECUTOR = 2;
const int MODULE_TYPE_FALLBACK = 3;
const int MODULE_TYPE_HOOK = 4;

const int HOOK_TYPE_GLOBAL = 0;
const int HOOK_TYPE_SIG = 1;

enum ModuleType {
  validator(value: MODULE_TYPE_VALIDATOR),
  executor(value: MODULE_TYPE_EXECUTOR),
  fallback(value: MODULE_TYPE_FALLBACK),
  hook(value: MODULE_TYPE_HOOK);

  final int value;
  const ModuleType({required this.value});
}

enum SafeHookType {
  global(value: HOOK_TYPE_GLOBAL),
  sig(value: HOOK_TYPE_SIG);

  final int value;
  const SafeHookType({required this.value});
}

typedef ModuleInitType = ModuleInit<EthereumAddress, Uint8List>;

class ModuleInit<T1 extends EthereumAddress, T2 extends Uint8List> {
  final T1 module;
  final T2 initData;

  ModuleInit(this.module, this.initData);
}

enum CallType {
  call(value: 0x00),
  batchcall(value: 0x01),
  delegatecall(value: 0xff);

  final int value;

  const CallType({required this.value});
}

class ExecutionMode {
  final CallType type;
  bool revertOnError;
  Uint8List? selector;
  Uint8List? context;

  ExecutionMode({
    required this.type,
    this.revertOnError = false,
    this.selector,
    this.context,
  });
}
