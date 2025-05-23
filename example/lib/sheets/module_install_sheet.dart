import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ModuleProvider>();
      provider.moduleList();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleInstall(
      BuildContext context, Base7579ModuleInterface module) async {
    final provider = context.read<ModuleProvider>();

    try {
      final response = await provider.installModule(module);

      if (!mounted) return;

      if (response.$1) {
        _showResultSnackBar(
          context,
          'Module installed successfully!\n${response.$2 != null ? 'Tx: ${response.$2?.txReceipt.transactionHash.shortenHash()}' : ''}',
          true,
        );
      } else {
        final errorMsg = response.$3?.toString() ?? 'Failed to install module';
        _showResultSnackBar(
          context,
          errorMsg,
          false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 150,
            left: 10,
            right: 10,
          ),
        ),
      );
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
            const SizedBox(height: 10),
            Consumer<ModuleProvider>(
              builder: (BuildContext context, provider, Widget? child) {
                final uninstalledModules = provider.uninstalledModules;

                if (provider.modules == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (uninstalledModules.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'All modules are installed',
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
                  itemCount: uninstalledModules.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    final module = uninstalledModules[index];
                    final isInstalling = provider.isInstalling(module.name);

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
                        trailing: isInstalling
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
                        onTap: isInstalling
                            ? null // Disable tap when installing
                            : () => _handleInstall(context, module),
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
