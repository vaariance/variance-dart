import 'package:flutter/material.dart';
import 'package:web3_signers/web3_signers.dart';
import '../constants/enums.dart';

/// Model for module entry in installation/uninstallation forms
class ModuleEntry {
  ModuleType? type;
  final TextEditingController addressController = TextEditingController();
  final TextEditingController initDataController = TextEditingController();

  void dispose() {
    addressController.dispose();
    initDataController.dispose();
  }
}

class InstalledModuleEntry {
  final ModuleType type;
  final EthereumAddress moduleAddress;
  final String initData;
  final bool isInstalled;

  InstalledModuleEntry({
    required this.type,
    required this.moduleAddress,
    required this.initData,
    required this.isInstalled,
  });

  // Copy with method (already existing)
  InstalledModuleEntry copyWith({
    ModuleType? type,
    EthereumAddress? moduleAddress,
    String? initData,
    bool? isInstalled,
  }) {
    return InstalledModuleEntry(
      type: type ?? this.type,
      moduleAddress: moduleAddress ?? this.moduleAddress,
      initData: initData ?? this.initData,
      isInstalled: isInstalled ?? this.isInstalled,
    );
  }

  // Add toMap method
  Map<String, dynamic> toMap() {
    return {
      'type': type.toString(),
      'moduleAddress': moduleAddress.hex,
      'initData': initData,
      'isInstalled': isInstalled,
    };
  }
}