import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/enums.dart';
import '../../providers/modular_account_provider.dart';
import '../../sheets/module_install_sheet.dart';
import '../../sheets/module_uninstall_sheet.dart';
import '../../sheets/module_verification_sheet.dart';
import '../modular_account/interface.dart';


/// Card widget for modular account management actions
class ModularActionsCard extends StatelessWidget {
  final ModularAccountInterface accountInterface;

  const ModularActionsCard({
    Key? key,
    required this.accountInterface,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric( vertical: 8),
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
        padding: const EdgeInsets.all(10),
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
                const SizedBox(width: 10),
                Text(
                  'Modular Account Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[200],
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
            ModuleInstallSheet(accountInterface: accountInterface)
          ],
        ),
      ),
    );
  }
}