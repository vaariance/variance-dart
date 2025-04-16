import 'package:flutter/material.dart';

import '../models/signer_options.dart';

/// Utility class for wallet-related operations
class WalletUtils {
  // Get light account options
  static List<SignerOption> getLightAccountOptions() {
    return [
      SignerOption(
        id: 'seedPhrase',
        name: 'Seed Phrase light account',
        icon: Icons.vpn_key,
        description: 'Create a light account with a seed phrase (12-word mnemonic)',
      ),
      SignerOption(
        id: 'privateKey',
        name: 'Private Key light account',
        icon: Icons.key,
        description: 'Create a light account with a random private key',
      ),
    ];
  }

  // Get safe account options
  static List<SignerOption> getSafeAccountOptions() {
    return [
      SignerOption(
        id: 'safe-seedPhrase',
        name: 'Seed Phrase (EOA Wallet)',
        icon: Icons.vpn_key,
        description: 'Create a Safe account with a seed phrase (12-word mnemonic)',
      ),
      SignerOption(
        id: 'safe-privateKey',
        name: 'Private Key',
        icon: Icons.key,
        description: 'Create a Safe account with a random private key',
      ),
      SignerOption(
        id: 'passkey',
        name: 'Passkey Authentication',
        icon: Icons.fingerprint,
        description: 'Create a Safe account using passkey biometric authentication',
      ),
      SignerOption(
        id: 'safeDefault',
        name: 'Default Safe Configuration',
        icon: Icons.shield_outlined,
        description: 'Create a Safe account with default settings',
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