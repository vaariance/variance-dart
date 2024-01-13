part of 'package:variance_dart/variance.dart';

mixin _PluginManager {
  final Map<String, dynamic> _plugins = {};

  ///returns a list of all active plugins
  List<String> activePlugins() {
    return _plugins.keys.toList(growable: false);
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
}
