import 'package:flutter/material.dart';
import 'package:variancedemo/constants/enums.dart';
import 'package:variancedemo/models/module_entry.dart';
import 'package:web3_signers/web3_signers.dart';

import '../models/signer_options.dart';

/// Utility class for wallet-related operations
class WalletUtils {
  // Get light account options
  static List<SignerOption> _createSignerOptions(AccountType type) {
    final baseOptions = [
      SignerOption(
        id: 'EOA',
        name: 'Seed Phrase',
        icon: Icons.vpn_key,
        description:
            'Create a ${type.name} account with a seed phrase (12-word mnemonic)',
        signers: SignerTypes.eoa,
        accountType: type,
      ),
      SignerOption(
        id: 'privateKey',
        name: 'Private Key',
        icon: Icons.key,
        description: 'Create a ${type.name} account with a random private key',
        signers: SignerTypes.privateKey,
        accountType: type,
      ),
    ];

    if (type != AccountType.light) {
      baseOptions.add(
        SignerOption(
          id: 'passkey',
          name: 'Passkey Authentication',
          icon: Icons.fingerprint,
          description:
              'Create a ${type.name} account using passkey biometric authentication',
          signers: SignerTypes.passkey,
          accountType: type,
        ),
      );
    }

    return baseOptions;
  }

  static List<SignerOption> getLightAccountOptions() =>
      _createSignerOptions(AccountType.light);

  static List<SignerOption> getSafeAccountOptions() =>
      _createSignerOptions(AccountType.safe);

  static List<SignerOption> get7579AccountOptions() =>
      _createSignerOptions(AccountType.modular);

  static List<InstalledModuleEntry> getModuleEntriesToInstall() {
    return [
      InstalledModuleEntry(
          type: ModuleType.socialRecovery,
          moduleAddress: EthereumAddress.fromHex(
              '0x5FbDB2315678afecb367f032d93F642f64180aa3'),
          initData: '0x',
          isInstalled: false),
      InstalledModuleEntry(
          type: ModuleType.registryHook,
          moduleAddress: EthereumAddress.fromHex(
              '0x5FbDB2315678afecb367f032d93F642f64180aa3'),
          initData: '0x',
          isInstalled: false),
      InstalledModuleEntry(
          type: ModuleType.ownableExecutor,
          moduleAddress: EthereumAddress.fromHex(
              '0x5FbDB2315678afecb367f032d93F642f64180aa3'),
          initData: '0x',
          isInstalled: false),
      InstalledModuleEntry(
          type: ModuleType.ownableValidator,
          moduleAddress: EthereumAddress.fromHex(
              '0x5FbDB2315678afecb367f032d93F642f64180aa3'),
          initData: '0x',
          isInstalled: false),
    ];
  }

  // Show toast message
  static void showToast(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Prevent instantiation
  WalletUtils._();
}
