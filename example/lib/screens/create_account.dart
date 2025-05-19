import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:variancedemo/constants/enums.dart';
import 'package:variancedemo/screens/widgets/loading_overlay.dart';
import 'package:variancedemo/screens/widgets/passkey_bottom_sheet.dart';
import '../models/signer_options.dart';
import '../models/wallet_creation_result.dart';
import '../providers/account_providers.dart';
import '../providers/wallet_provider.dart';
import '../utils/utils.dart';
import '../utils/widgets.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccountProvider()),
      ],
      child: _CreateAccountContent(),
    );
  }
}

class _CreateAccountContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final walletProvider = context.watch<WalletProvider>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        appBar: AppBar(
          title: const Text('Create Account'),
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          leading: BackButton(color: Theme.of(context).colorScheme.onPrimary),
        ),
        body: LoadingOverlay(
          isLoading: accountProvider.isLoading ||
              walletProvider.creationState == WalletCreationState.loading,
          message: accountProvider.loadingMessage,
          child: SingleChildScrollView(
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
                    title: 'Create Light Account',
                    icon: Icons.bolt_outlined,
                    color: const Color(0xFF663399),
                    isExpanded: accountProvider.isLightAccountExpanded,
                    onToggle: () =>
                        accountProvider.toggleLightAccountExpanded(),
                    options: accountProvider.lightAccountOptions,
                    selectedSigner: accountProvider.selectedLightSigner,
                    onSelect: (option) =>
                        _handleOptionSelected(context, option),
                  ),

                  const SizedBox(height: 16),

                  // Safe Account Dropdown
                  AccountDropdown(
                    title: 'Create Safe Account',
                    icon: Icons.shield_outlined,
                    color: const Color(0xFF663399),
                    isExpanded: accountProvider.isSafeAccountExpanded,
                    onToggle: () => accountProvider.toggleSafeAccountExpanded(),
                    options: accountProvider.safeAccountOptions,
                    selectedSigner: accountProvider.selectedSafeSigner,
                    onSelect: (option) =>
                        _handleOptionSelected(context, option),
                  ),

                  const SizedBox(height: 16),

                  // Safe Account Dropdown
                  AccountDropdown(
                    title: 'Create Modular account',
                    icon: Icons.view_module,
                    color: const Color(0xFF663399),
                    isExpanded: accountProvider.is7579AccountExpanded,
                    onToggle: () => accountProvider.toggle7579AccountExpanded(),
                    options: accountProvider.modularAccountOptions,
                    selectedSigner: accountProvider.selected7579Signer,
                    onSelect: (option) =>
                        _handleOptionSelected(context, option),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleOptionSelected(
      BuildContext context, SignerOption option) async {
    final accountProvider = context.read<AccountProvider>();
    final walletProvider = context.read<WalletProvider>();

  
    handleCreate() {
      return _createWallet(context, option.id, option.accountType);
    }

    if (option.id == 'passkey') {
      PasskeyBottomSheet.show(context, handleCreate);
      return;
    }

    accountProvider.setLoading(message: 'Creating ${option.name}...');

    try {
      final result = await handleCreate();

      if (result.success) {
        Navigator.pushReplacementNamed(context, '/home');
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

  Future<WalletCreationResult> _createWallet(
      BuildContext context, String optionId, AccountType accountType) async {
    final walletProvider = context.read<WalletProvider>();

    switch (optionId) {
      case 'passkey':
        switch (accountType) {
          case AccountType.modular:
            return await walletProvider.createModularWallet(optionId);
          default:
            return await walletProvider.createSafeWallet(optionId);
        }
      default:
        switch (accountType) {
          case AccountType.light:
            return await walletProvider.createLightWallet(optionId);
          case AccountType.modular:
            return await walletProvider.createModularWallet(optionId);
          default:
            return await walletProvider.createSafeWallet(optionId);
        }
    }
  }
}
