import 'package:flutter/material.dart';
import 'package:variance_dart/variance_dart.dart';
import 'package:variance_modules/modules.dart';
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
  // ignore: unused_field
  DateTime? _lastFetched;

  ModuleProvider(this._wallet) {
    final owners = [_guardian1.address, _guardian2.address];

    ownableValidator = OwnableValidator(_wallet, threshold, owners);
    socialRecovery = SocialRecovery(_wallet, threshold, owners);
    ownableExecutor = OwnableExecutor(_wallet, _guardian1.address);
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
      return Modules([], modules);
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
    _lastFetched = DateTime.now();

    return result;
  }

  Future<Modules> reloadModules() async {
    final fresh = await moduleList(forceRefresh: true);
    notifyListeners();
    return fresh;
  }

  void clearCache() {
    _cachedModules = null;
    _lastFetched = null;
  }
}
