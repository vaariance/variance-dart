import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:variance_dart/variance_dart.dart';
import 'package:variance_modules/modules.dart';
import 'package:variancedemo/providers/module_provider.dart';

import '../utils/hex.dart';

class ModuleUninstallSheet extends StatefulWidget {
  const ModuleUninstallSheet({
    super.key,
  });

  @override
  ModuleUninstallSheetState createState() => ModuleUninstallSheetState();
}

class ModuleUninstallSheetState extends State<ModuleUninstallSheet> {
  ModuleType? selectedType;
  final TextEditingController addressController = TextEditingController();
  final TextEditingController initDataController = TextEditingController();
  bool isMultipleModules = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    addressController.dispose();
    initDataController.dispose();
    super.dispose();
  }

  void _handleUninstall(BuildContext context, Base7579ModuleInterface module,
      Future<Modules> Function() reloadModules) async {
    try {
      final response = await _processUninstallation(module);
      await reloadModules();
      Navigator.pop(context);

      _showResultSnackbar(
        context,
        response.$1
            ? 'Module uninstalled successfully: ${response.$2 != null ? '\nTx: ${response.$2?.txReceipt.transactionHash.shortenHash()}' : ''}'
            : 'Failed to uninstall module: ${response.$3.toString()}',
        response.$1,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<(bool, UserOperationReceipt?, dynamic)> _processUninstallation(
      Base7579ModuleInterface module) async {
    try {
      log('Installing: ${module.name}');
      final tx = await module.uninstall();
      log('Installed: ${module.name}');
      return (true, tx, null);
    } catch (e) {
      return (false, null, e);
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
            Consumer<ModuleProvider>(
                builder: (BuildContext context, provider, Widget? child) {
              return FutureBuilder<Modules>(
                future: provider.moduleList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red));
                  }

                  final installedModules = snapshot.data?.installed ?? [];

                  if (installedModules.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No installed modules to uninstall',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: installedModules.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      final module = installedModules[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF363647),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF663399).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 2),
                          title: Text(
                            module.name,
                            style: TextStyle(
                              color: Colors.grey[200],
                              fontSize: 16,
                            ),
                          ),
                          onTap: () => _handleUninstall(
                              context, module, provider.reloadModules),
                        ),
                      );
                    },
                  );
                },
              );
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
