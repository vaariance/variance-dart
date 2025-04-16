import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/wallet_provider.dart';
import '../../utils/utils.dart';

class PasskeyBottomSheet extends StatefulWidget {
  const PasskeyBottomSheet({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PasskeyBottomSheet(),
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
                backgroundColor: const Color(0xffE1FF01),
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
                ),
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

    Navigator.pop(context);

    setState(() {
      isLoading = true;
    });

    try {
      final walletProvider = context.read<WalletProvider>();
      final result = await walletProvider.registerWithPassKey(
        usernameController.text,
        requiresUserVerification: true,
      );

      if (!result.success) {
        WalletUtils.showToast(context, walletProvider.errorMessage, isError: true);
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      WalletUtils.showToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}