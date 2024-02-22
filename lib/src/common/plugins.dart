part of 'package:variance_dart/variance.dart';

typedef Percent = double;

class GasSettings {
  Percent? gasMultiplierPercentage;
  Percent? pvgx;
  BigInt? userDefinedMaxFeePerGas;
  BigInt? userDefinedMaxPriorityFeePerGas;
  bool retryFailedSendUserOp;

  GasSettings({
    this.gasMultiplierPercentage = 0,
    this.userDefinedMaxFeePerGas,
    this.userDefinedMaxPriorityFeePerGas,
    this.retryFailedSendUserOp = false,
    this.pvgx = 0.2,
  }) : assert(gasMultiplierPercentage! >= 0 && pvgx! > 0 && pvgx <= 0.2,
            'Gas multiplier percentage or pvgx is out of permissible bounds.');
}

mixin _GasSettings {
  GasSettings _gasParams = GasSettings();

  set setGasParams(GasSettings gasParams) => _gasParams = gasParams;

  UserOperation multiply(UserOperation op) {
    op = op.copyWith(
        preVerificationGas:
            op.preVerificationGas * BigInt.from(_gasParams.pvgx! + 1),
        maxFeePerGas: _gasParams.userDefinedMaxFeePerGas,
        maxPriorityFeePerGas: _gasParams.userDefinedMaxPriorityFeePerGas);

    final multiplier = _gasParams.gasMultiplierPercentage! > 0
        ? BigInt.from(_gasParams.gasMultiplierPercentage! + 1)
        : BigInt.one;

    op = op.copyWith(
      callGasLimit: op.callGasLimit * multiplier,
      verificationGasLimit: op.verificationGasLimit * multiplier,
      preVerificationGas: op.preVerificationGas * multiplier,
    );

    return op;
  }

  dynamic retryOp(Function callback, dynamic err) {
    if (_gasParams.retryFailedSendUserOp) {
      return callback();
    }
    throw err;
  }
}

mixin _PluginManager {
  final Map<String, dynamic> _plugins = {};

  ///returns a list of all active plugins
  List<String> activePlugins() {
    return _plugins.keys.toList(growable: false);
  }

  /// Adds a plugin by name.
  ///
  /// Parameters:
  ///   - `name`: The name of the plugin to add.
  ///   - `module`: The instance of the plugin.
  ///
  /// Example:
  /// ```dart
  /// addPlugin('logger', Logger());
  /// ```
  void addPlugin<T>(String name, T module) {
    _plugins[name] = module;
  }

  /// Gets a plugin by name.
  ///
  /// Parameters:
  ///   - `name`: The name of the plugin to retrieve.
  ///
  /// Returns:
  ///   The plugin with the specified name.
  T plugin<T>(String name) {
    return _plugins[name] as T;
  }

  /// Removes an unwanted plugin by name.
  ///
  /// Parameters:
  ///   - `name`: The name of the plugin to remove.
  ///
  /// Example:
  /// ```dart
  /// removePlugin('logger');
  /// ```
  void removePlugin(String name) {
    _plugins.remove(name);
  }
}
