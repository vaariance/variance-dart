mixin Modules {
  final Map<String, dynamic> _modules = {};

  ///returns a list of all active modules
  List<String> activeModules() {
    return _modules.keys.toList(growable: false);
  }

  ///gets a [module] by name
  T module<T>(String name) {
    return _modules[name] as T;
  }

  /// removes an unwanted module by [name]
  void removeModule(String name) {
    _modules.remove(name);
  }

  ///Sets a [module] by name
  void setModule<T>(String name, T module) {
    _modules[name] = module;
  }
}
