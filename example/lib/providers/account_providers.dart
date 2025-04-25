import 'package:flutter/material.dart';
import 'package:variancedemo/models/module_entry.dart';
import '../constants/enums.dart';
import '../models/signer_options.dart';
import '../utils/utils.dart';

/// Provider to manage account creation UI state
class AccountProvider extends ChangeNotifier {
  // UI state for dropdowns
  bool _isLightAccountExpanded = false;
  bool _isSafeAccountExpanded = false;
  bool _is7579AccountExpanded = false;

  // Selected signer types
  String? _selectedLightSigner;
  String? _selectedSafeSigner;
  String? _selected7579Signer;

  // Loading state
  bool _isLoading = false;
  String _loadingMessage = 'Creating account...';

  final List<InstalledModuleEntry> _moduleEntries =
      WalletUtils.getModuleEntriesToInstall();

  // Getter that returns the stored list
  List<InstalledModuleEntry> get moduleEntriesToInstall => _moduleEntries;

  // Getter for dropdown states
  bool get isLightAccountExpanded => _isLightAccountExpanded;
  bool get isSafeAccountExpanded => _isSafeAccountExpanded;
  bool get is7579AccountExpanded => _is7579AccountExpanded;

  // Getters for selected signers
  String? get selectedLightSigner => _selectedLightSigner;
  String? get selectedSafeSigner => _selectedSafeSigner;
  String? get selected7579Signer => _selected7579Signer;

  // Loading state getters
  bool get isLoading => _isLoading;
  String get loadingMessage => _loadingMessage;

  // Account options (cached)
  final List<SignerOption> _lightAccountOptions =
      WalletUtils.getLightAccountOptions();
  final List<SignerOption> _safeAccountOptions =
      WalletUtils.getSafeAccountOptions();
  final List<SignerOption> _7579AccountOptions =
      WalletUtils.get7579AccountOptions();

  // Getters for options
  List<SignerOption> get lightAccountOptions => _lightAccountOptions;
  List<SignerOption> get safeAccountOptions => _safeAccountOptions;
  List<SignerOption> get modularAccountOptions => _7579AccountOptions;

  // Methods to toggle dropdown states
  void toggleLightAccountExpanded() {
    _isLightAccountExpanded = !_isLightAccountExpanded;
    if (_isLightAccountExpanded) {
      _isSafeAccountExpanded = false;
      _is7579AccountExpanded = false;
    }
    notifyListeners();
  }

  void toggleSafeAccountExpanded() {
    _isSafeAccountExpanded = !_isSafeAccountExpanded;
    if (_isSafeAccountExpanded) {
      _isLightAccountExpanded = false;
      _is7579AccountExpanded = false;
    }
    notifyListeners();
  }

  void toggle7579AccountExpanded() {
    _is7579AccountExpanded = !_is7579AccountExpanded;
    if (_is7579AccountExpanded) {
      _isLightAccountExpanded = false;
      _isSafeAccountExpanded = false;
    }
    notifyListeners();
  }

  // Methods to select signer types
  void selectLightSigner(String signerId) {
    _selectedLightSigner = signerId;
    _selectedSafeSigner = null;
    _selected7579Signer = null;
    notifyListeners();
  }

  void selectSafeSigner(String signerId) {
    _selectedSafeSigner = signerId;
    _selectedLightSigner = null;
    _selected7579Signer = null;
    notifyListeners();
  }

  void select7579Signer(String signerId) {
    _selected7579Signer = signerId;
    _selectedSafeSigner = null;
    _selectedLightSigner = null;
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

  // Methods to manage loading state
  void setLoading({String message = 'Creating account...'}) {
    _isLoading = true;
    _loadingMessage = message;
    notifyListeners();
  }

  void clearLoading() {
    _isLoading = false;
    notifyListeners();
  }

  // Helper to get selected signer option
  SignerOption? getSelectedSignerOption() {
    if (_selectedLightSigner != null) {
      return _lightAccountOptions.firstWhere(
        (option) => option.id == _selectedLightSigner,
        orElse: () => SignerOption(
            id: '', name: '', icon: Icons.error, signers: SignerTypes.none),
      );
    } else if (_selectedSafeSigner != null) {
      return _safeAccountOptions.firstWhere(
        (option) => option.id == _selectedSafeSigner,
        orElse: () => SignerOption(
            id: '', name: '', icon: Icons.error, signers: SignerTypes.none),
      );
    } else if (_selected7579Signer != null) {
      return _7579AccountOptions.firstWhere(
        (option) => option.id == _selected7579Signer,
        orElse: () => SignerOption(
            id: '', name: '', icon: Icons.error, signers: SignerTypes.none),
      );
    }

    return null;
  }

  // Reset all state
  void resetState() {
    _isLightAccountExpanded = false;
    _isSafeAccountExpanded = false;
    _is7579AccountExpanded = false;
    _selectedLightSigner = null;
    _selectedSafeSigner = null;
    _selected7579Signer = null;
    _isLoading = false;
    notifyListeners();
  }
}
