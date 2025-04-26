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

  final int threshold = 2;
  final PrivateKeySigner _guardian1 = PrivateKeySigner.createRandom("test");
  final PrivateKeySigner _guardian2 = PrivateKeySigner.createRandom("test");

  late final Base7579ModuleInterface socialRecovery;
  late final Base7579ModuleInterface ownableExecutor;
  late final Base7579ModuleInterface registryHook;
  late final Base7579ModuleInterface ownableValidator;

  ModuleProvider(this._wallet) {
    final owners = [_guardian1.address, _guardian2.address];

    OwnableValidator.setInitVars(threshold, owners);
    SocialRecovery.setInitVars(threshold, owners);

    ownableValidator = OwnableValidator(_wallet);
    socialRecovery = SocialRecovery(_wallet);
    ownableExecutor = OwnableExecutor(_wallet);
    registryHook = RegistryHook(_wallet);
  }

  List<Base7579ModuleInterface> _getAllModules() {
    return [socialRecovery, ownableExecutor, registryHook, ownableValidator];
  }

  Future<Modules> moduleList() async {
    final modules = _getAllModules();
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
    return Modules(installed, uninstalled);
  }
}
