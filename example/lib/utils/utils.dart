import 'package:flutter/material.dart';
import 'package:variancedemo/constants/enums.dart';
import 'package:variancedemo/models/module_entry.dart';
import 'package:web3_signers/web3_signers.dart';

import '../models/signer_options.dart';

/// Utility class for wallet-related operations
class WalletUtils {
  // Get light account options
  static List<SignerOption> getLightAccountOptions() {
    return [
      SignerOption(
        id: 'EOA',
        name: 'Seed Phrase light account',
        icon: Icons.vpn_key,
        description: 'Create a light account with a seed phrase (12-word mnemonic)',
        signers: SignerTypes.eoa
      ),
      SignerOption(
        id: 'privateKey',
        name: 'Private Key light account',
        icon: Icons.key,
        description: 'Create a light account with a random private key',
          signers: SignerTypes.privateKey
      ),
    ];
  }

  // Get safe account options
  static List<SignerOption> getSafeAccountOptions() {
    return [
      SignerOption(
        id: 'EOA',
        name: 'Seed Phrase (EOA Wallet)',
        icon: Icons.vpn_key,
        description: 'Create a Safe account with a seed phrase (12-word mnemonic)',
          signers: SignerTypes.eoa
      ),
      SignerOption(
        id: 'privateKey',
        name: 'Private Key',
        icon: Icons.key,
        description: 'Create a Safe account with a random private key',
          signers: SignerTypes.privateKey
      ),
      SignerOption(
        id: 'passkey',
        name: 'Passkey Authentication',
        icon: Icons.fingerprint,
        description: 'Create a Safe account using passkey biometric authentication',
          signers: SignerTypes.passkey
      ),
    ];
  }
  static List<SignerOption> get7579AccountOptions () {
    return [
      SignerOption(
        id: 'EOA',
        name: 'Seed Phrase Modular account',
        icon: Icons.vpn_key,
        description: 'Create 7579 modular account with a seed phrase (12-word mnemonic)',
          signers: SignerTypes.eoa,
          accountType: AccountType.modular
      ),
      SignerOption(
        id: 'privateKey',
        name: 'Private Key Modular account',
        icon: Icons.key,
        description: 'Create 7579 modular account with a random private key',
          signers: SignerTypes.privateKey,
          accountType: AccountType.modular
      ),
      SignerOption(
        id: 'passkey',
        name: 'Passkey Authentication',
        icon: Icons.fingerprint,
        description: 'Create 7579 modular account using passkey biometric authentication',
          signers: SignerTypes.passkey,
        accountType: AccountType.passkeyModular
      ),
    ];
  }

  static List<SignerOption> getRegistryAccountOptions () {
    return [
      SignerOption(
        id: 'EOA',
        name: 'Seed Phrase Registry Account',
        icon: Icons.vpn_key,
        description: 'Create 7579 modular account with a seed phrase (12-word mnemonic)',
          signers: SignerTypes.eoa,
        accountType: AccountType.modular
      ),
      SignerOption(
        id: 'privateKey',
        name: 'Private Key Registry Account',
        icon: Icons.key,
        description: 'Create 7579 modular account with a random private key',
          signers: SignerTypes.privateKey,
        accountType: AccountType.modular
      ),
      SignerOption(
        id: 'passkey',
        name: 'Passkey Registry Account',
        icon: Icons.fingerprint,
        description: 'Create 7579 modular account using passkey biometric authentication',
          signers: SignerTypes.passkey,
        accountType: AccountType.passkeyModular
      ),
    ];
  }

  static List<InstalledModuleEntry> getModuleEntriesToInstall (){
    return [
      InstalledModuleEntry(
        type: ModuleType.socialRecovery,
         moduleAddress: EthereumAddress.fromHex('0x5FbDB2315678afecb367f032d93F642f64180aa3'),
       initData: '0x',
        isInstalled: false
      ),
      InstalledModuleEntry(
          type: ModuleType.registryHook,
          moduleAddress: EthereumAddress.fromHex('0x5FbDB2315678afecb367f032d93F642f64180aa3'),
          initData: '0x',
          isInstalled: false
      ),
      InstalledModuleEntry(
          type: ModuleType.ownableExecutor,
          moduleAddress: EthereumAddress.fromHex('0x5FbDB2315678afecb367f032d93F642f64180aa3'),
          initData: '0x',
          isInstalled: false
      ),
      InstalledModuleEntry(
          type: ModuleType.ownableValidator,
          moduleAddress: EthereumAddress.fromHex('0x5FbDB2315678afecb367f032d93F642f64180aa3'),
          initData: '0x',
          isInstalled: false
      ),
    ];

  }
  // Show toast message
  static void showToast(BuildContext context, String message, {bool isError = false}) {
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