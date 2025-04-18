import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:typed_data';

import '../constants/enums.dart';
import '../models/module_entry.dart';
import '../providers/modular_account_provider.dart';
import '../screens/modular_account/interface.dart';
import '../utils/hex.dart';


class ModuleInstallSheet extends StatefulWidget {
  final ModularAccountInterface accountInterface;

  const ModuleInstallSheet({
    super.key,
    required this.accountInterface,
  });

  @override
  ModuleInstallSheetState createState() => ModuleInstallSheetState();
}

class ModuleInstallSheetState extends State<ModuleInstallSheet> {
  ModuleType? selectedType;
  final TextEditingController addressController = TextEditingController();
  final TextEditingController initDataController = TextEditingController();
  bool isMultipleModules = false;
  final List<ModuleEntry> moduleEntries = [];

  @override
  void initState() {
    super.initState();
    moduleEntries.add(ModuleEntry());
  }

  @override
  void dispose() {
    addressController.dispose();
    initDataController.dispose();
    for (var entry in moduleEntries) {
      entry.dispose();
    }
    super.dispose();
  }

  void _handleInstall(BuildContext context) async {
    final accountProvider = context.read<ModularAccountsProvider>();
    accountProvider.setLoading(
        message: 'Installing ${isMultipleModules ? 'modules' : 'module'}...');

    try {
      final response = await _processInstallation();
      accountProvider.clearLoading();
      Navigator.pop(context);

      _showResultSnackbar(
        context,
        response.success
            ? 'Module${isMultipleModules ? 's' : ''} installed successfully${response.transactionHash != null ? '\nTx: ${HexUtils.shortenHash(response.transactionHash!)}' : ''}'
            : 'Failed to install module${isMultipleModules ? 's' : ''}: ${response.message ?? 'Unknown error'}',
        response.success,
      );
    } catch (e) {
      accountProvider.clearLoading();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future _processInstallation() async {
    if (isMultipleModules) {
      // Process multiple modules installation
      final validModules = moduleEntries
          .where((module) =>
      module.type != null &&
          module.addressController.text.isNotEmpty &&
          module.initDataController.text.isNotEmpty)
          .toList();

      if (validModules.isEmpty) {
        throw Exception('Please fill all required fields');
      }

      final types = validModules.map((m) => m.type!).toList();
      final addresses = validModules
          .map((m) => EthereumAddress.fromHex(m.addressController.text))
          .toList();
      final initDatas = validModules
          .map((m) =>
          Uint8List.fromList(HexUtils.hexToBytes(m.initDataController.text)))
          .toList();

      return await widget.accountInterface
          .installModules(types, addresses, initDatas);
    } else {
      // Process single module installation
      if (selectedType == null ||
          addressController.text.isEmpty ||
          initDataController.text.isEmpty) {
        throw Exception('Please fill all required fields');
      }

      return await widget.accountInterface.installModule(
        selectedType!,
        EthereumAddress.fromHex(addressController.text),
        Uint8List.fromList(HexUtils.hexToBytes(initDataController.text)),
      );
    }
  }

  void _showResultSnackbar(BuildContext context, String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2A2A3C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  List<Widget> _buildSingleModuleForm() {
    return [
      DropdownButtonFormField<ModuleType>(
        value: selectedType,
        hint: Text('Select Module Type',
            style: TextStyle(color: Colors.grey[400])),
        dropdownColor: const Color(0xFF2A2A3C),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          filled: true,
          fillColor: const Color(0xFF1F1F2C),
        ),
        style: TextStyle(color: Colors.grey[200]),
        items: ModuleType.values.map((type) {
          return DropdownMenuItem<ModuleType>(
            value: type,
            child: Text(type.toString().split('.').last),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedType = value;
          });
        },
      ),
      const SizedBox(height: 15),
      TextFormField(
        controller: addressController,
        decoration: InputDecoration(
          labelText: 'Module Address',
          labelStyle: TextStyle(color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          filled: true,
          fillColor: const Color(0xFF1F1F2C),
          prefixIcon: Icon(Icons.link, color: Colors.grey[400]),
        ),
        style: TextStyle(color: Colors.grey[200]),
      ),
      const SizedBox(height: 15),
      TextFormField(
        controller: initDataController,
        decoration: InputDecoration(
          labelText: 'Init Data (hex)',
          labelStyle: TextStyle(color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          filled: true,
          fillColor: const Color(0xFF1F1F2C),
          prefixIcon: Icon(Icons.code, color: Colors.grey[400]),
        ),
        style: TextStyle(color: Colors.grey[200]),
      ),
    ];
  }

  List<Widget> _buildMultipleModulesForm() {
    return [
      ...moduleEntries.asMap().entries.map((entry) {
        final index = entry.key;
        final module = entry.value;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: const Color(0xFF1F1F2C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: const Color(0xFF663399).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Module ${index + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[200],
                      ),
                    ),
                    if (moduleEntries.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          setState(() {
                            moduleEntries.removeAt(index);
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<ModuleType>(
                  value: module.type,
                  hint: Text('Select Module Type',
                      style: TextStyle(color: Colors.grey[400])),
                  dropdownColor: const Color(0xFF2A2A3C),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1F1F2C).withOpacity(0.5),
                  ),
                  style: TextStyle(color: Colors.grey[200]),
                  items: ModuleType.values.map((type) {
                    return DropdownMenuItem<ModuleType>(
                      value: type,
                      child: Text(type.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      module.type = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: module.addressController,
                  decoration: InputDecoration(
                    labelText: 'Module Address',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1F1F2C).withOpacity(0.5),
                    prefixIcon: Icon(Icons.link, color: Colors.grey[400]),
                  ),
                  style: TextStyle(color: Colors.grey[200]),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: module.initDataController,
                  decoration: InputDecoration(
                    labelText: 'Init Data (hex)',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1F1F2C).withOpacity(0.5),
                    prefixIcon: Icon(Icons.code, color: Colors.grey[400]),
                  ),
                  style: TextStyle(color: Colors.grey[200]),
                ),
              ],
            ),
          ),
        );
      }).toList(),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            setState(() {
              moduleEntries.add(ModuleEntry());
            });
          },
          icon: const Icon(Icons.add, color: Color(0xFF663399)),
          label: const Text(
            'Add Another Module',
            style: TextStyle(color: Color(0xFF663399)),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF663399)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A3C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Install Module',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[200],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[400]),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              value: isMultipleModules,
              onChanged: (value) {
                setState(() {
                  isMultipleModules = value;
                  if (!value && moduleEntries.length > 1) {
                    moduleEntries.clear();
                    moduleEntries.add(ModuleEntry());
                  }
                });
              },
              title: Text(
                'Install Multiple Modules',
                style: TextStyle(color: Colors.grey[200]),
              ),
              activeColor: const Color(0xFF663399),
            ),
            const SizedBox(height: 10),
            if (isMultipleModules)
              ..._buildMultipleModulesForm()
            else
              ..._buildSingleModuleForm(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleInstall(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF663399),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Install ${isMultipleModules ? 'Modules' : 'Module'}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}