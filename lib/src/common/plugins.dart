part of 'package:variance_dart/variance.dart';

mixin _PluginManager {
  final Map<String, dynamic> _plugins = {};

  ///returns a list of all active plugins
  List<String> activePlugins() {
    return _plugins.keys.toList(growable: false);
  }

  ///gets a [plugin] by name
  T plugin<T>(String name) {
    return _plugins[name] as T;
  }

  /// removes an unwanted plugin by [name]
  void removePlugin(String name) {
    _plugins.remove(name);
  }

  ///adds a [plugin] by name
  void addPlugin<T>(String name, T module) {
    _plugins[name] = module;
  }
}
