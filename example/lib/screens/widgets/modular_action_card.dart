import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:variancedemo/models/modular_account_impl.dart';
import 'package:variancedemo/providers/account_providers.dart';
import '../../constants/enums.dart';
import '../../sheets/module_install_sheet.dart';
import '../../sheets/module_uninstall_sheet.dart';
import '../../sheets/module_verification_sheet.dart';

/// Card widget for modular account management actions
class ModularActionsCard extends StatelessWidget {
  final Home7579InterfaceImpl accountInterface;

  const ModularActionsCard({
    Key? key,
    required this.accountInterface,
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
      builder: (context) =>
          ModuleInstallSheet(accountInterface: accountInterface),
    );
  }

  void _showUninstallModuleDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ModuleUninstallSheet(accountInterface: accountInterface),
    );
  }

  void _checkModuleSupport(BuildContext context) async {
    final moduleType = await _showModuleTypeSelector(context);
    if (moduleType != null) {
      final accountProvider = context.read<AccountProvider>();
      accountProvider.setLoading(message: 'Checking module support...');

      try {
        final isSupported = await accountInterface.supportsModule(moduleType);
        accountProvider.clearLoading();

        _showResultDialog(
          context,
          'Module Support Check',
          'This account ${isSupported == true ? 'supports' : 'does not support'} the ${moduleType.toString().split('.').last} module type.',
          isSupported == true ? Icons.check_circle : Icons.cancel,
          isSupported == true ? Colors.green : Colors.red,
        );
      } catch (e) {
        accountProvider.clearLoading();
        _showErrorDialog(
            context, 'Failed to check module support: ${e.toString()}');
      }
    }
  }

  void _verifyInstalledModule(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ModuleVerificationSheet(accountInterface: accountInterface),
    );

    if (result != null && result is Map<String, dynamic>) {
      final accountProvider = context.read<AccountProvider>();
      accountProvider.setLoading(message: 'Verifying module installation...');

      try {
        final isInstalled = await accountInterface.isModuleInstalled(
          result['moduleType'],
          result['moduleAddress'],
          result['context'],
        );

        accountProvider.clearLoading();

        _showResultDialog(
          context,
          'Module Verification',
          'The module ${isInstalled == true ? 'is' : 'is not'} installed.',
          isInstalled == true ? Icons.check_circle : Icons.cancel,
          isInstalled == true ? Colors.green : Colors.red,
        );
      } catch (e) {
        accountProvider.clearLoading();
        _showErrorDialog(context, 'Failed to verify module: ${e.toString()}');
      }
    }
  }

  void _getAccountId(BuildContext context) async {
    final accountProvider = context.read<AccountProvider>();
    accountProvider.setLoading(message: 'Retrieving account ID...');

    try {
      final accountId = await accountInterface.accountId();
      accountProvider.clearLoading();

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
      accountProvider.clearLoading();
      _showErrorDialog(context, 'Failed to get account ID: ${e.toString()}');
    }
  }

  Future<ModuleType?> _showModuleTypeSelector(BuildContext context) async {
    return await showModalBottomSheet<ModuleType>(
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
            ...ModuleType.values
                .map((type) => ListTile(
                      title: Text(
                        type.toString().split('.').last,
                        style: TextStyle(color: Colors.grey[200]),
                      ),
                      onTap: () => Navigator.pop(context, type),
                    ))
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
