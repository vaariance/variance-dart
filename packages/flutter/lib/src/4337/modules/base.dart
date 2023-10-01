mixin Modules {
  Map<String, dynamic> modules = {};

  void setModule<T>(String name, T module) {
    modules[name] = module;
  }

  T module<T>(String name) {
    return modules[name] as T;
  }

  void removeModule(String name) {
    modules.remove(name);
  }

  List<String> activeModules() {
    return modules.keys.toList(growable: false);
  }
}
