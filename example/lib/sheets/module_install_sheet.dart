import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:variancedemo/models/modular_account_impl.dart';
import 'package:variancedemo/providers/account_providers.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:typed_data';

import '../constants/enums.dart';
import '../models/module_entry.dart';
import '../utils/hex.dart';

class ModuleInstallSheet extends StatefulWidget {
  final Home7579InterfaceImpl accountInterface;

  const ModuleInstallSheet({
    super.key,
    required this.accountInterface,
  });

  @override
  ModuleInstallSheetState createState() => ModuleInstallSheetState();
}

class ModuleInstallSheetState extends State<ModuleInstallSheet> {
  ModuleType? selectedType;
  bool isMultipleModules = false;
  final List<InstalledModuleEntry> moduleEntries = [];

  @override
  void initState() {
    super.initState();
    moduleEntries.add(InstalledModuleEntry(
        moduleAddress: EthereumAddress.fromHex(
            '0x5FbDB2315678afecb367f032d93F642f64180aa3'),
        initData: '0x',
        type: ModuleType.none,
        isInstalled: false));
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleInstall(BuildContext context, InstalledModuleEntry module) async {
    final accountProvider = context.read<AccountProvider>();
    accountProvider.setLoading(
        message: 'Installing ${isMultipleModules ? 'modules' : 'module'}...');

    try {
      final response = await _processInstallation(module);
      accountProvider.clearLoading();
      _showResultSnackBar(
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

  Future _processInstallation(InstalledModuleEntry moduleToInstall) async {
    final accountProvider = context.read<AccountProvider>();

    log('Installing: ${moduleToInstall.type}');

    final installed = await widget.accountInterface.installModule(
      moduleToInstall.type,
      moduleToInstall.moduleAddress,
      Uint8List.fromList(HexUtils.hexToBytes(moduleToInstall.initData)),
    );
    accountProvider.setInstalledModule(installed.type);
    log('Installed: ${accountProvider.moduleEntriesToInstall[0].toMap()}');

    return installed;
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[200],
              ),
            ),
            Consumer<AccountProvider>(
              builder: (BuildContext context, provider, Widget? child) {
                final uninstalledModules = provider.uninstalledModule;
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
                      onTap: () => _handleInstall(context, module),
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
