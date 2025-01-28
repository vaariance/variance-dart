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
  late final bool _7579ActionsEnabled;
  @override
  noSuchMethod(Invocation invocation) {
    if (_7579ActionsEnabled) {
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

  void _setup7579Actions(SmartWalletType type) {
    if (type == SmartWalletType.Safe7579) {
      _7579ActionsEnabled = true;
    } else {
      _7579ActionsEnabled = false;
    }
  }
}
