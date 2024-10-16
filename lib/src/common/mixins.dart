part of '../../variance_dart.dart';

typedef Percent = double;

/// A class that represents gas settings for Ethereum transactions.
class GasSettings {
  /// The percentage by which the gas limits should be multiplied.
  ///
  /// This value should be between 0 and 100.
  Percent callGasMultiplierPercentage;
  Percent verificationGasMultiplierPercentage;
  Percent preVerificationGasMultiplierPercentage;

  /// The user-defined maximum fee per gas for the transaction.
  BigInt? userDefinedMaxFeePerGas;

  /// The user-defined maximum priority fee per gas for the transaction.
  BigInt? userDefinedMaxPriorityFeePerGas;

  /// Creates a new instance of the [GasSettings] class.
  ///
  /// [gasMultiplierPercentage] is the percentage by which the gas limits should be multiplied.
  /// Defaults to 0.
  ///
  /// [userDefinedMaxFeePerGas] is the user-defined maximum fee per gas for the transaction.
  ///
  /// [userDefinedMaxPriorityFeePerGas] is the user-defined maximum priority fee per gas for the transaction.
  ///
  /// An assertion is made to ensure that [gasMultiplierPercentage] is between 0 and 100.
  GasSettings({
    this.callGasMultiplierPercentage = 0,
    this.verificationGasMultiplierPercentage = 0,
    this.preVerificationGasMultiplierPercentage = 0,
    this.userDefinedMaxFeePerGas,
    this.userDefinedMaxPriorityFeePerGas,
  }) : assert(
            callGasMultiplierPercentage >= 0 &&
                callGasMultiplierPercentage <= 100 &&
                verificationGasMultiplierPercentage >= 0 &&
                preVerificationGasMultiplierPercentage >= 0,
            RangeOutOfBounds("Wrong Gas multiplier percentage", 0, 100));
}

/// A mixin that provides methods for managing gas settings for user operations.
mixin _GasSettings {
  /// The gas settings for user operations.
  GasSettings _gasParams = GasSettings();

  /// Sets the gas settings for user operations.
  ///
  /// [gasParams] is an instance of the [GasSettings] class containing the gas settings.
  set gasSettings(GasSettings gasParams) => _gasParams = gasParams;

  /// Applies the gas settings to a user operation, by multiplying the gas limits by a certain percentage.
  ///
  /// [op] is the user operation to which the gas settings should be applied.
  ///
  /// Returns a new [UserOperation] object with the updated gas settings.
  UserOperation applyCustomGasSettings(UserOperation op) {
    final cglMultiplier = _gasParams.callGasMultiplierPercentage / 100 + 1;
    final vglMultiplier =
        _gasParams.verificationGasMultiplierPercentage / 100 + 1;
    final preVglMultiplier =
        _gasParams.preVerificationGasMultiplierPercentage / 100 + 1;
    final multiplier = cglMultiplier * vglMultiplier * preVglMultiplier;

    if (multiplier == 1 &&
        _gasParams.userDefinedMaxFeePerGas == null &&
        _gasParams.userDefinedMaxPriorityFeePerGas == null) return op;

    return op.copyWith(
        callGasLimit: BigInt.from(op.callGasLimit.toDouble() * cglMultiplier),
        verificationGasLimit:
            BigInt.from(op.verificationGasLimit.toDouble() * vglMultiplier),
        preVerificationGas:
            BigInt.from(op.preVerificationGas.toDouble() * preVglMultiplier),
        maxFeePerGas: _gasParams.userDefinedMaxFeePerGas,
        maxPriorityFeePerGas: _gasParams.userDefinedMaxPriorityFeePerGas);
  }
}

/// Used to manage the plugins used in the [Smartwallet] instance
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
