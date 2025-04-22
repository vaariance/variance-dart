import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:variancedemo/constants/enums.dart';
import 'package:variancedemo/providers/modular_account_provider.dart';
import 'package:variancedemo/screens/widgets/loading_overlay.dart';
import 'package:variancedemo/screens/widgets/passkey_bottom_sheet.dart';

import '../../models/signer_options.dart';
import '../../models/wallet_creation_result.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/utils.dart';
import '../../utils/widgets.dart';



class Eip7579Screen extends StatelessWidget {
  const Eip7579Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<ModularAccountsProvider>();
    final walletProvider = context.watch<WalletProvider>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        title: const Text('EIP-7579'),
        leading: BackButton(color: Theme.of(context).colorScheme.onPrimary,),
      ),
      body: LoadingOverlay(isLoading: accountProvider.isLoading || walletProvider.creationState == WalletCreationState.loading ,
          message: accountProvider.loadingMessage,
          child:SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFE6E6FA),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your preferred account type and authentication method',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Light Account Dropdown
                  AccountDropdown(
                    title: '7579 Modular account',
                    icon: Icons.view_module,
                    color: const Color(0xFF663399),
                    isExpanded: accountProvider.is7579AccountExpanded,
                    onToggle: () => accountProvider.toggle7579AccountExpanded(),
                    options: accountProvider.modularAccountOptions,
                    selectedSigner: accountProvider.selected7579Signer,
                    onSelect: (option) => _handleOptionSelected(context, option),
                  ),

                  const SizedBox(height: 16),

                  // Safe Account Dropdown
                  AccountDropdown(
                    title: 'Registry Hook account',
                    icon: Icons.shield_outlined,
                    color: const Color(0xFF663399),
                    isExpanded: accountProvider.isRegistryHookAccountExpanded,
                    onToggle: () => accountProvider.toggleRegistryHookAccountExpanded(),
                    options: accountProvider.registryHookAccountOptions,
                    selectedSigner: accountProvider.selectedRegistryHookSigner,
                    onSelect: (option) => _handleOptionSelected(context, option),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
      ),
    );
  }
}

Future<void> _handleOptionSelected(BuildContext context, SignerOption option) async {
  final accountProvider = context.read<ModularAccountsProvider>();
  final walletProvider = context.read<WalletProvider>();

  if (accountProvider.modularAccountOptions.contains(option)) {
    accountProvider.select7579Signer(option.id);
  } else if(accountProvider.registryHookAccountOptions.contains(option)) {
    accountProvider.selectRegistryHookSigner(option.id);
  }

  if (option.id == 'passkey') {
    PasskeyBottomSheet.show(context);
    return;
  }

  accountProvider.setLoading(message: 'Creating ${option.name}...');

  try {
    final result = await _createWallet(context, option.id);

    if (result.success) {
      Navigator.pushReplacementNamed(context, '/home', arguments: AppEnums.modularAccounts);
    } else {
      WalletUtils.showToast(
        context,
        walletProvider.errorMessage.isNotEmpty
            ? walletProvider.errorMessage
            : 'Failed to create wallet',
        isError: true,
      );
    }
  } catch (e) {
    WalletUtils.showToast(context, e.toString(), isError: true);
  } finally {
    accountProvider.clearLoading();
  }
}

Future<WalletCreationResult> _createWallet(BuildContext context, String optionId) async {
  final walletProvider = context.read<WalletProvider>();

  switch (optionId) {
    case 'seedPhrase':
      return await walletProvider.createEOAWallet();

    case 'privateKey':
      return await walletProvider.createPrivateKeyWallet();

    case 'safe-seedPhrase':
      return await walletProvider.createSafeEOAWallet();

    case 'safe-privateKey':
      return await walletProvider.createSafePrivateKeyWallet();

    case 'safeDefault':
      return await walletProvider.createSafeWallet();

    default:
      throw ArgumentError('Unknown option ID: $optionId');
  }
}
