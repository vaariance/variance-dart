import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:variancedemo/models/module_entry.dart';

import '../constants/enums.dart';
import '../models/signer_options.dart';
import '../utils/utils.dart';

/// A provider for managing modular account state
class ModularAccountsProvider extends ChangeNotifier {
  // Dropdown expand states
  bool _is7579AccountExpanded = false;
  bool _registryHookAccountExpanded = false;

  // Selected signers
  String? _selected7579Signer;
  String? _selectedRegistryHookSigner;

  // Loading state
  bool _isLoading = false;
  String _loadingMessage = 'Creating account...';

  // setters
  ModuleType? _isInstalled;

  // Getters
  bool get is7579AccountExpanded => _is7579AccountExpanded;
  bool get isRegistryHookAccountExpanded => _registryHookAccountExpanded;
  String? get selected7579Signer => _selected7579Signer;
  String? get selectedRegistryHookSigner => _selectedRegistryHookSigner;
  bool get isLoading => _isLoading;
  String get loadingMessage => _loadingMessage;

  // Account options
  final List<SignerOption> _7579AccountOptions;
  final List<SignerOption> _registryHookAccountOptions;

  List<SignerOption> get modularAccountOptions => _7579AccountOptions;
  List<SignerOption> get registryHookAccountOptions =>
      _registryHookAccountOptions;

  final List<InstalledModuleEntry> _moduleEntries = WalletUtils.getModuleEntriesToInstall();

  // Getter that returns the stored list
  List<InstalledModuleEntry> get moduleEntriesToInstall => _moduleEntries;

  // Constructor
  ModularAccountsProvider({
    required List<SignerOption> modularAccountOptions,
    required List<SignerOption> registryHookAccountOptions,
  })  : _7579AccountOptions = modularAccountOptions,
        _registryHookAccountOptions = registryHookAccountOptions;

  /// Toggle the dropdown expansion for 7579 accounts
  void toggle7579AccountExpanded() {
    _is7579AccountExpanded = !_is7579AccountExpanded;
    if (_is7579AccountExpanded) {
      _registryHookAccountExpanded = false;
    }
    notifyListeners();
  }

  /// Toggle the dropdown expansion for registry hook accounts
  void toggleRegistryHookAccountExpanded() {
    _registryHookAccountExpanded = !_registryHookAccountExpanded;
    if (_registryHookAccountExpanded) {
      _is7579AccountExpanded = false;
    }
    notifyListeners();
  }

  /// Select a 7579 signer
  void select7579Signer(String signerId) {
    _selected7579Signer = signerId;
    _selectedRegistryHookSigner = null;
    notifyListeners();
  }

  /// Select a registry hook signer
  void selectRegistryHookSigner(String signerId) {
    _selectedRegistryHookSigner = signerId;
    _selected7579Signer = null;
    notifyListeners();
  }

  /// Set loading state with message
  void setLoading({String message = 'Creating account...'}) {
    _isLoading = true;
    _loadingMessage = message;
    notifyListeners();
  }

  void setInstalledModule(ModuleType moduleType) {
    for (var i = 0; i < _moduleEntries.length; i++) {
      if (_moduleEntries[i].type == moduleType) {
        _moduleEntries[i] = _moduleEntries[i].copyWith(isInstalled: true);
        notifyListeners();
        break;
      }
    }
  }

  void setUninstallModule(ModuleType moduleType) {
    for (var i = 0; i < _moduleEntries.length; i++) {
      if (_moduleEntries[i].type == moduleType) {
        _moduleEntries[i] = _moduleEntries[i].copyWith(isInstalled: false);
        notifyListeners();
        break;
      }
    }
  }

  List<InstalledModuleEntry> get uninstalledModule {
    return moduleEntriesToInstall
        .where((module) => module.isInstalled == false)
        .toList();
  }

  List<InstalledModuleEntry> get installedModules =>
      _moduleEntries.where((module) => module.isInstalled).toList();
  /// Clear loading state
  void clearLoading() {
    _isLoading = false;
    notifyListeners();
  }

  /// Get the selected signer option
  SignerOption? getSelectedSignerOption() {
    if (_selected7579Signer != null) {
      return _7579AccountOptions.firstWhere(
        (option) => option.id == _selected7579Signer,
        orElse: () => SignerOption(
            id: '', name: '', icon: Icons.error, signers: SignerTypes.none),
      );
    } else if (_selectedRegistryHookSigner != null) {
      return _registryHookAccountOptions.firstWhere(
        (option) => option.id == _selectedRegistryHookSigner,
        orElse: () => SignerOption(
            id: '', name: '', icon: Icons.error, signers: SignerTypes.none),
      );
    }
    return null;
  }

  /// Reset all state
  void resetState() {
    _is7579AccountExpanded = false;
    _registryHookAccountExpanded = false;
    _selected7579Signer = null;
    _selectedRegistryHookSigner = null;
    _isLoading = false;
    notifyListeners();
  }
}

/// Represents a signer option for account creation
