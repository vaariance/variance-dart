import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:variance_dart/variance_dart.dart';
import 'package:variance_modules/modules.dart';
import 'package:variancedemo/providers/module_provider.dart';
import 'package:variancedemo/providers/wallet_provider.dart';
import 'package:web3dart/web3dart.dart';
import '../../sheets/module_install_sheet.dart';
import '../../sheets/module_uninstall_sheet.dart';
import '../../sheets/module_verification_sheet.dart';

/// Card widget for modular account management actions
class ModularActionsCard extends StatelessWidget {
  const ModularActionsCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFF2A2A3C),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
            // Title
            Row(
              children: [
                const Icon(
                  Icons.extension,
                  color: Color(0xFF663399),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Modular Account Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[200],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Manage modules for your EIP-7579 account',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 20),

            // Module Management Options
            _buildActionButton(
              context,
              'Install Module',
              Icons.add_circle_outline,
              () => _showInstallModuleDialog(context),
              const Color(0xFF663399),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              'Uninstall Module',
              Icons.remove_circle_outline,
              () => _showUninstallModuleDialog(context),
              const Color(0xFF8A4FC7),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              'Check Module Support',
              Icons.check_circle_outline,
              () => _checkModuleSupport(context),
              const Color(0xFFA371E1),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              'Verify Installed Module',
              Icons.fact_check_outlined,
              () => _verifyInstalledModule(context),
              const Color(0xFFBE9DE3),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              'Get Account ID',
              Icons.account_circle_outlined,
              () => _getAccountId(context),
              const Color(0xFFC7B8E3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
    Color color,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.1),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[200],
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showInstallModuleDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ModuleInstallSheet(),
    );
  }

  void _showUninstallModuleDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ModuleUninstallSheet(),
    );
  }

  void _checkModuleSupport(BuildContext context) async {
    final mod = await _showModuleTypeSelector(context);
    if (mod != null) {
      final wallet = context.read<WalletProvider>().wallet;

      try {
        final isSupported = await wallet?.supportsModule(mod.type);

        _showResultDialog(
          context,
          'Module Support Check',
          'This account ${isSupported == true ? 'supports' : 'does not support'} the ${mod.type.name} module type.',
          isSupported == true ? Icons.check_circle : Icons.cancel,
          isSupported == true ? Colors.green : Colors.red,
        );
      } catch (e) {
        _showErrorDialog(
            context, 'Failed to check module support: ${e.toString()}');
      }
    }
  }

  void _verifyInstalledModule(BuildContext context) async {
    final (ModuleType?, EthereumAddress, Uint8List?)? result =
        await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ModuleVerificationSheet(),
    );

    if (result != null && result.$1 != null) {
      final wallet = context.read<WalletProvider>().wallet;

      try {
        final isInstalled =
            await wallet?.isModuleInstalled(result.$1!, result.$2, result.$3);

        _showResultDialog(
          context,
          'Module Verification',
          'The module ${isInstalled == true ? 'is' : 'is not'} installed.',
          isInstalled == true ? Icons.check_circle : Icons.cancel,
          isInstalled == true ? Colors.green : Colors.red,
        );
      } catch (e) {
        _showErrorDialog(context, 'Failed to verify module: ${e.toString()}');
      }
    }
  }

  void _getAccountId(BuildContext context) async {
    final wallet = context.read<WalletProvider>().wallet;

    try {
      final accountId = await wallet?.accountId();

      if (accountId != null) {
        _showResultDialog(
          context,
          'Account ID',
          'Your account ID is:\n\n$accountId',
          Icons.account_balance_wallet,
          const Color(0xFF663399),
        );
      } else {
        _showErrorDialog(context, 'Could not retrieve account ID.');
      }
    } catch (e) {
      _showErrorDialog(context, 'Failed to get account ID: ${e.toString()}');
    }
  }

  Future<Base7579ModuleInterface?> _showModuleTypeSelector(
      BuildContext context) async {
    final provider = context.read<ModuleProvider>();
    final modules = await provider.moduleList();

    return await showModalBottomSheet<Base7579ModuleInterface>(
      context: context,
      backgroundColor: const Color(0xFF2A2A3C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Module Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20),
            ...modules.getAll
                .map((mod) => Container(
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
                        mod.name,
                        style: TextStyle(color: Colors.grey[200], fontSize: 14),
                      ),
                      onTap: () => Navigator.pop(context, mod),
                    )))
                .toList(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showResultDialog(
    BuildContext context,
    String title,
    String message,
    IconData icon,
    Color iconColor,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: Colors.grey[200]),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF663399)),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent),
            const SizedBox(width: 10),
            Text(
              'Error',
              style: TextStyle(color: Colors.grey[200]),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF663399)),
            ),
          ),
        ],
      ),
    );
  }
}
