import 'package:flutter/material.dart';
import '../models/signer_options.dart';
import '../utils/utils.dart';

/// Provider to manage account creation UI state
class AccountProvider extends ChangeNotifier {
  // UI state for dropdowns
  bool _isLightAccountExpanded = false;
  bool _isSafeAccountExpanded = false;

  // Selected signer types
  String? _selectedLightSigner;
  String? _selectedSafeSigner;

  // Loading state
  bool _isLoading = false;
  String _loadingMessage = 'Creating account...';

  // Getter for dropdown states
  bool get isLightAccountExpanded => _isLightAccountExpanded;
  bool get isSafeAccountExpanded => _isSafeAccountExpanded;

  // Getters for selected signers
  String? get selectedLightSigner => _selectedLightSigner;
  String? get selectedSafeSigner => _selectedSafeSigner;

  // Loading state getters
  bool get isLoading => _isLoading;
  String get loadingMessage => _loadingMessage;

  // Account options (cached)
  final List<SignerOption> _lightAccountOptions = WalletUtils.getLightAccountOptions();
  final List<SignerOption> _safeAccountOptions = WalletUtils.getSafeAccountOptions();

  // Getters for options
  List<SignerOption> get lightAccountOptions => _lightAccountOptions;
  List<SignerOption> get safeAccountOptions => _safeAccountOptions;

  // Methods to toggle dropdown states
  void toggleLightAccountExpanded() {
    _isLightAccountExpanded = !_isLightAccountExpanded;
    if (_isLightAccountExpanded) {
      _isSafeAccountExpanded = false;
    }
    notifyListeners();
  }

  void toggleSafeAccountExpanded() {
    _isSafeAccountExpanded = !_isSafeAccountExpanded;
    if (_isSafeAccountExpanded) {
      _isLightAccountExpanded = false;
    }
    notifyListeners();
  }

  // Methods to select signer types
  void selectLightSigner(String signerId) {
    _selectedLightSigner = signerId;
    _selectedSafeSigner = null;
    notifyListeners();
  }

  void selectSafeSigner(String signerId) {
    _selectedSafeSigner = signerId;
    _selectedLightSigner = null;
    notifyListeners();
  }

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
          id: '',
          name: '',
          icon: Icons.error,
        ),
      );
    } else if (_selectedSafeSigner != null) {
      return _safeAccountOptions.firstWhere(
            (option) => option.id == _selectedSafeSigner,
        orElse: () => SignerOption(
          id: '',
          name: '',
          icon: Icons.error,
        ),
      );
    }

    return null;
  }

  // Reset all state
  void resetState() {
    _isLightAccountExpanded = false;
    _isSafeAccountExpanded = false;
    _selectedLightSigner = null;
    _selectedSafeSigner = null;
    _isLoading = false;
    notifyListeners();
  }
}