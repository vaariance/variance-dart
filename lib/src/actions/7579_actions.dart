part of '../../variance_dart.dart';

abstract interface class _7579Interface {
  void installModule(int a);
  void installModules();
  void uninstallModule();
  void uninstallModules();
  void supportsModule();
  void isModuleInstalled();
  void supportsExecutionMode();
  void accountId();
  void executeFromExecutor();
}

mixin _7579Actions on SmartWalletBase implements _7579Interface {
  late final _SafeInitializer? _initializer;

  bool get is7579Enabled =>
      _initializer != null && _initializer is _Safe7579Initializer;

  @override
  noSuchMethod(Invocation invocation) {
    if (_initializer != null) {
      final posArgs = invocation.positionalArguments;
      switch (invocation.memberName) {
        case #installModule:
          return _installModule(posArgs[0]);
        case #installModules:
          print("true");
          return "invoked";
        case #uninstallModule:
          print("true");
          return "invoked";
        case #uninstallModules:
          print("true");
          return "invoked";
        case #supportsModule:
          print("true");
          return "invoked";
        case #isModuleInstalled:
          print("true");
          return "invoked";
        case #supportsExecutionMode:
          print("true");
          return "invoked";
        case #accountId:
          print("true");
          return "invoked";
        case #executeFromExecutor:
          print("true");
          return "invoked";
        default:
          break;
      }
    }
    throw NoSuchMethodError.withInvocation(this, invocation);
  }

  void _installModule(int a);
  void _installModules();
  void _uninstallModule();
  void _uninstallModules();
  void _supportsModule();
  void _isModuleInstalled();
  void _supportsExecutionMode();
  void _accountId();
  void _executeFromExecutor();

  void _setup7579Actions(_SafeInitializer? initializer) {
    _initializer = initializer;
  }

  Future<Uint8List> get7579ExecuteCalldata({
    required EthereumAddress to,
    EtherAmount? amount,
    Uint8List? innerCallData,
  }) async {
    final calldata = to.addressBytes
        .concat(
          intToBytes(amount?.getInWei ?? EtherAmount.zero().getInWei)
              .padLeftTo32Bytes(),
        )
        .concat(innerCallData ?? Uint8List.fromList([]));
    final isNotInitial = await isDeployed;
    return isNotInitial
        ? encode7579Call(
            ExecutionMode(type: CallType.call), [calldata], address)
        : _encodePostSetupInitCalldata(_initializer as _Safe7579Initializer,
            [calldata], address, CallType.call);
  }

  Future<Uint8List> get7579ExecuteBatchCalldata({
    required List<EthereumAddress> recipients,
    List<EtherAmount>? amounts,
    List<Uint8List>? innerCalls,
  }) async {
    final calls = recipients
        .asMap()
        .entries
        .map(
          (entry) => entry.value.addressBytes
              .concat(
                intToBytes(amounts?[entry.key].getInWei ??
                        EtherAmount.zero().getInWei)
                    .padLeftTo32Bytes(),
              )
              .concat(innerCalls?[entry.key] ?? Uint8List.fromList([])),
        )
        .toList();
    final bool isNotInitial = await isDeployed;
    return isNotInitial
        ? encode7579Call(
            ExecutionMode(type: CallType.batchcall), calls, address)
        : _encodePostSetupInitCalldata(_initializer as _Safe7579Initializer,
            calls, address, CallType.batchcall);
  }
}
