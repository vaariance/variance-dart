import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ModuleProvider>();
      provider.moduleList();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleUninstall(
      BuildContext context, Base7579ModuleInterface module) async {
    final provider = context.read<ModuleProvider>();

    try {
      final response = await provider.uninstallModule(module);

      if (!mounted) return;

      if (response.$1) {
        if (context.mounted) {
          Navigator.pop(context);
          _showResultSnackbar(
            context,
            'Module uninstalled successfully!\n${response.$2 != null ? 'Tx: ${response.$2?.txReceipt.transactionHash.shortenHash()}' : ''}',
            true,
          );
        }
      } else {
        if (context.mounted) {
          _showResultSnackbar(
            context,
            response.$3?.toString() ?? 'Failed to uninstall module',
            false,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showResultSnackbar(
          context,
          'Unexpected error: ${e.toString()}',
          false,
        );
      }
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
              child: Text(
                message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2A2A3C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: success ? 4 : 6),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          left: 10,
          right: 10,
        ),
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
                final installedModules = provider.installedModules;

                if (provider.modules == null) {
                  return const Center(child: CircularProgressIndicator());
                }

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
                    final isUninstalling = provider.isUninstalling(module.name);

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF363647),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF663399).withValues(alpha: 0.3),
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
                        trailing: isUninstalling
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF663399),
                                  ),
                                ),
                              )
                            : null,
                        onTap: isUninstalling
                            ? null // Disable tap when uninstalling
                            : () => _handleUninstall(context, module),
                      ),
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
