import 'package:flutter/material.dart';
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