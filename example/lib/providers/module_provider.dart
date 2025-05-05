import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:variance_dart/variance_dart.dart';
import 'package:variance_modules/modules.dart';
import 'package:variancedemo/utils/exceptions.dart';
import 'package:web3_signers/web3_signers.dart';

class Modules {
  final List<Base7579ModuleInterface> installed;
  final List<Base7579ModuleInterface> uninstalled;

  Modules(this.installed, this.uninstalled);

  List<Base7579ModuleInterface> get getAll => [...installed, ...uninstalled];
}

class ModuleProvider extends ChangeNotifier {
  final SmartWallet _wallet;

  final BigInt threshold = BigInt.two;
  final PrivateKeySigner _guardian1 = PrivateKeySigner.createRandom("test");
  final PrivateKeySigner _guardian2 = PrivateKeySigner.createRandom("test");

  late final Base7579ModuleInterface socialRecovery;
  late final Base7579ModuleInterface ownableExecutor;
  late final Base7579ModuleInterface ownableValidator;

  Modules? _cachedModules;

  final Map<String, bool> _installingModules = {};
  final Map<String, bool> _uninstallingModules = {};

  ModuleProvider(this._wallet) {
    final owners = [_guardian1.address, _guardian2.address];

    ownableValidator = OwnableValidator(_wallet, threshold, owners);
    socialRecovery = SocialRecovery(_wallet, threshold, owners);
    ownableExecutor = OwnableExecutor(_wallet, _guardian1.address);
  }

  Modules? get modules => _cachedModules;

  List<Base7579ModuleInterface> get uninstalledModules =>
      _cachedModules?.uninstalled ?? [];

  List<Base7579ModuleInterface> get installedModules =>
      _cachedModules?.installed ?? [];

  bool isInstalling(String moduleName) {
    return _installingModules[moduleName] ?? false;
  }

  bool isUninstalling(String moduleName) {
    return _uninstallingModules[moduleName] ?? false;
  }

  List<Base7579ModuleInterface> _getAllModules() {
    return [socialRecovery, ownableExecutor, ownableValidator];
  }

  Future<Modules> moduleList({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedModules != null) {
      return _cachedModules!;
    }

    final modules = _getAllModules();
    final isWalletDeployed = await _wallet.isDeployed;
    if (!isWalletDeployed) {
      final result = Modules([], modules);
      _cachedModules = result;
      notifyListeners();
      return result;
    }

    final installed = <Base7579ModuleInterface>[];

    await Future.wait(modules.map((mod) async {
      final isInstalled =
          await _wallet.isModuleInstalled(mod.type, mod.address) ?? false;
      if (isInstalled) {
        installed.add(mod);
      }
    }));

    final uninstalled =
        modules.where((mod) => !installed.contains(mod)).toList();

    final result = Modules(installed, uninstalled);
    _cachedModules = result;
    notifyListeners();

    return result;
  }

  Future<Modules> reloadModules() async {
    final fresh = await moduleList(forceRefresh: true);
    return fresh;
  }

  void clearCache() {
    _cachedModules = null;

    notifyListeners();
  }

  Future<(bool, UserOperationReceipt?, dynamic)> installModule(
      Base7579ModuleInterface module) async {
    _installingModules[module.name] = true;
    notifyListeners();

    try {
      log('Installing: ${module.name}');
      final tx = await module.install();
      log('Installed: ${module.name}');

      await reloadModules();

      return (true, tx, null);
    } catch (e) {
      String errorMessage = parseUserOperationError(e);

      log('Failed to install module: ${e.toString()}');
      return (false, null, ModuleInstallationException(errorMessage, e));
    } finally {
      _installingModules[module.name] = false;
      notifyListeners();
    }
  }

  Future<(bool, UserOperationReceipt?, dynamic)> uninstallModule(
      Base7579ModuleInterface module) async {
    _uninstallingModules[module.name] = true;
    notifyListeners();

    try {
      log('Uninstalling: ${module.name}');
      final tx = await module.uninstall();
      log('Uninstalled: ${module.name}');

      await reloadModules();

      return (true, tx, null);
    } catch (e) {
      String errorMessage = parseUserOperationError(e);
      return (false, null, ModuleInstallationException(errorMessage, e));
    } finally {
      _uninstallingModules[module.name] = false;
      notifyListeners();
    }
  }
}
