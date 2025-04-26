import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:variance_dart/variance_dart.dart';
import 'package:variance_modules/modules.dart';
import 'package:variancedemo/providers/module_provider.dart';

import '../utils/hex.dart';

class ModuleInstallSheet extends StatefulWidget {
  final ModuleProvider? moduleProvider;

  const ModuleInstallSheet({
    super.key,
    this.moduleProvider,
  });

  @override
  ModuleInstallSheetState createState() => ModuleInstallSheetState();
}

class ModuleInstallSheetState extends State<ModuleInstallSheet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleInstall(BuildContext context, Base7579ModuleInterface module,
      Future<Modules> Function() reloadModules) async {
    try {
      final response = await _processInstallation(module);
      await reloadModules();
      _showResultSnackBar(
        context,
        response.$1
            ? 'Module installed successfully: ${response.$2 != null ? '\nTx: ${response.$2?.txReceipt.transactionHash.shortenHash()}' : ''}'
            : 'Failed to install module: ${response.$3.toString()}',
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

  Future<(bool, UserOperationReceipt?, dynamic)> _processInstallation(
      Base7579ModuleInterface moduleToInstall) async {
    try {
      log('Installing: ${moduleToInstall.name}');
      final tx = await moduleToInstall.install();
      log('Installed: ${moduleToInstall.name}');
      return (true, tx, null);
    } catch (e) {
      return (false, null, e);
    }
  }

  void _showResultSnackBar(BuildContext context, String message, bool success) {
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
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A3C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Select any module to install',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[200],
              ),
            ),
            Consumer<ModuleProvider>(
              builder: (BuildContext context, provider, Widget? child) {
                return FutureBuilder<Modules>(
                  future: provider.moduleList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      print(snapshot.error);
                      print(snapshot.stackTrace);
                      return Text('Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red));
                    }

                    final uninstalledModules = snapshot.data?.uninstalled ?? [];

                    return ListView.builder(
                      itemCount: uninstalledModules.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        final module = uninstalledModules[index];
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
                            onTap: () => _handleInstall(
                                context, module, provider.reloadModules),
                          ),
                        );
                      },
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
