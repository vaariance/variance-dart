import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:variancedemo/models/modular_account_impl.dart';
import 'package:variancedemo/providers/account_providers.dart';
import 'dart:typed_data';

import '../constants/enums.dart';
import '../models/module_entry.dart';
import '../utils/hex.dart';

class ModuleUninstallSheet extends StatefulWidget {
  final Home7579InterfaceImpl accountInterface;

  const ModuleUninstallSheet({
    super.key,
    required this.accountInterface,
  });

  @override
  ModuleUninstallSheetState createState() => ModuleUninstallSheetState();
}

class ModuleUninstallSheetState extends State<ModuleUninstallSheet> {
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

  void _handleUninstall(
      BuildContext context, InstalledModuleEntry module) async {
    final accountProvider = context.read<AccountProvider>();
    accountProvider.setLoading(
        message: 'Uninstalling ${isMultipleModules ? 'modules' : 'module'}...');

    try {
      final response = await _processUninstallation(module);
      accountProvider.clearLoading();
      Navigator.pop(context);

      _showResultSnackbar(
        context,
        response.success
            ? 'Module${isMultipleModules ? 's' : ''} uninstalled successfully${response.transactionHash != null ? '\nTx: ${HexUtils.shortenHash(response.transactionHash!)}' : ''}'
            : 'Failed to uninstall module${isMultipleModules ? 's' : ''}: ${response.message ?? 'Unknown error'}',
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

  Future _processUninstallation(InstalledModuleEntry moduleToInstall) async {
    final accountProvider = context.read<AccountProvider>();

    log('Installing: ${moduleToInstall.type}');

    final installed = await widget.accountInterface.uninstallModule(
      moduleToInstall.type,
      moduleToInstall.moduleAddress,
      Uint8List.fromList(HexUtils.hexToBytes(moduleToInstall.initData)),
    );
    accountProvider.setUninstallModule(moduleToInstall.type);
    log('Installed: ${accountProvider.moduleEntriesToInstall[0].toMap()}');

    return installed;
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
                  'Uninstall Module',
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
            Consumer<AccountProvider>(
              builder: (BuildContext context, provider, Widget? child) {
                final uninstalledModules = provider.installedModules;
                log('Uninstalled modules: ${uninstalledModules.length}');
                return ListView.builder(
                  itemCount: uninstalledModules.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    final module = uninstalledModules[index];
                    return ListTile(
                      title: Text(module.type.name,
                          style: TextStyle(color: Colors.grey[200])),
                      onTap: () => _handleUninstall(context, module),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
