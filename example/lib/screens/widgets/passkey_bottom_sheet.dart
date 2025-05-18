import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/wallet_creation_result.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/utils.dart';

class PasskeyBottomSheet extends StatefulWidget {
  final Future<WalletCreationResult> Function() handleCreate;
  
  const PasskeyBottomSheet({
    Key? key,
    required this.handleCreate,
  }) : super(key: key);

  static void show(BuildContext context, Future<WalletCreationResult> Function() handleCreate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PasskeyBottomSheet(handleCreate: handleCreate),
    );
  }

  @override
  State<PasskeyBottomSheet> createState() => _PasskeyBottomSheetState();
}

class _PasskeyBottomSheetState extends State<PasskeyBottomSheet> {
  final TextEditingController usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Create Account with Passkey',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),

          // Form
          Form(
            key: _formKey,
            child: TextFormField(
              controller: usernameController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a username';
                }
                if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                  return 'Username must contain only alphabets with no spaces';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Enter your username',
                fillColor: Colors.grey[100],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Continue button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF663399),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Continue',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final walletProvider = context.read<WalletProvider>();

    try {
      // Use the handleCreate function passed from the widget
      final result = await widget.handleCreate();

      if (!mounted) return;

      if (result.success) {
        Navigator.of(context).pop(); // Dismiss bottom sheet
        // Navigate after current frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        });
      } else {
        WalletUtils.showToast(
          context,
          walletProvider.errorMessage.isNotEmpty
              ? walletProvider.errorMessage
              : 'Passkey creation failed. Please try again.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      String message = e.toString().contains('CredManProvService')
          ? 'Failed to create passkey. Make sure you have a supported device or Google Account.'
          : e.toString();

      WalletUtils.showToast(context, message, isError: true);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}
