part of '../../variance_dart.dart';

mixin _7579Actions on SmartWalletBase {
  late final bool _actionsEnabled;

  sampleAction() {
    _onlyWhenEnabled(() {
      // this is my action
    });
  }

  T _onlyWhenEnabled<T>(T Function() action) {
    if (!_actionsEnabled) {
      throw Exception("Safe 7579 Actions cannot be used with this Account!");
    }
    return action();
  }

  void _setup7579Actions(SmartWalletType type) {
    if (type == SmartWalletType.Safe7579) {
      _actionsEnabled = true;
    } else {
      _actionsEnabled = false;
    }
  }
}
