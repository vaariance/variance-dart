part of '../../variance.dart';

typedef Percent = double;

class GasSettings {
  Percent? gasMultiplierPercentage;
  BigInt? userDefinedMaxFeePerGas;
  BigInt? userDefinedMaxPriorityFeePerGas;
  bool retryFailedSendUserOp;

  GasSettings({
    this.gasMultiplierPercentage = 0,
    this.userDefinedMaxFeePerGas,
    this.userDefinedMaxPriorityFeePerGas,
    this.retryFailedSendUserOp = false,
  }) : assert(gasMultiplierPercentage! >= 0,
            'Gas multiplier percentage should be 0 to 100');
}

mixin _GasSettings {
  GasSettings _gasParams = GasSettings();

  set setGasParams(GasSettings gasParams) => _gasParams = gasParams;

  UserOperation multiply(UserOperation op) {
    final multiplier =
        BigInt.from(_gasParams.gasMultiplierPercentage! / 100 + 1);

    return op.copyWith(
        callGasLimit: op.callGasLimit * multiplier,
        verificationGasLimit: op.verificationGasLimit * multiplier,
        preVerificationGas: op.preVerificationGas * multiplier,
        maxFeePerGas: _gasParams.userDefinedMaxFeePerGas,
        maxPriorityFeePerGas: _gasParams.userDefinedMaxPriorityFeePerGas);
  }

  Future<UserOperationResponse> retryOp(
      Future<UserOperationResponse> Function() callback, dynamic err) {
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
  ///   - `name`: Optional. The name of the plugin to retrieve.
  ///
  /// Returns:
  ///   The plugin with the specified name.
  T plugin<T>([String? name]) {
    if (name == null) {
      for (var plugin in _plugins.values) {
        if (plugin is T) {
          return plugin;
        }
      }
    }
    return _plugins[name] as T;
  }

  /// checks if a plugin exists
  ///
  /// Parameters:
  ///   - `name`: The name of the plugin to check
  ///
  /// Returns:
  ///   true if the plugin exists
  bool hasPlugin(String name) {
    return _plugins.containsKey(name);
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
