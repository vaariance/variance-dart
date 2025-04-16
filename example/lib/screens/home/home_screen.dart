import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:variancedemo/providers/wallet_provider.dart';
import 'package:variancedemo/screens/home/home_widgets.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoadingTransfer = false;
  bool _isLoadingMint = false;
  String _transferTxHash = '';
  String _mintTxHash = '';

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final walletAddress = walletProvider.wallet?.address.hex ?? 'Not connected';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      appBar: AppBar(
         backgroundColor: Theme.of(context).colorScheme.onSurface,
        title: const Text('Wallet Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/create-account');
            },
          ),
        ],
        leading: BackButton(color: Theme.of(context).colorScheme.onPrimary,),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WalletBalance(),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wallet Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      walletAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            // ERC20 Transfer Action
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 220,
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingTransfer ? null : () => _showSendDialog(context),
                    icon: _isLoadingTransfer
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blue,
                      ),
                    )
                        : const Icon(Icons.send, color: Colors.blue),
                    label: Text(
                      _isLoadingTransfer ? 'Sending...' : 'Simulate ERC20 Transfer',
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                if (_transferTxHash.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transaction Hash:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _transferTxHash,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 16),
                                onPressed: () => _copyToClipboard(_transferTxHash),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingMint ? null : () => _mintNFT(context),
                    icon: _isLoadingMint
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.purple,
                      ),
                    )
                        : const Icon(Icons.image, color: Colors.purple),
                    label: Text(
                      _isLoadingMint ? 'Minting...' : 'Simulate Mint NFT',
                      style: const TextStyle(
                        color: Colors.purple,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.purple,
                      backgroundColor: Colors.purple.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),

                if (_mintTxHash.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transaction Hash:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _mintTxHash,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 16),
                                onPressed: () => _copyToClipboard(_mintTxHash),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showSendDialog(BuildContext context) async {
    final TextEditingController recipientController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: recipientController,
              decoration: const InputDecoration(
                labelText: 'Recipient Address',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _sendTransaction(
                context,
                recipientController.text,
                amountController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendTransaction(
      BuildContext context,
      String recipient,
      String amount,
      ) async {
    final walletProvider = context.read<WalletProvider>();

    setState(() {
      _isLoadingTransfer = true;
    });

    try {
      final (success, hash) = await walletProvider.sendTransaction(recipient, amount);

      setState(() {
        _isLoadingTransfer = false;
        if (success && hash.isNotEmpty) {
          _transferTxHash = hash;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Transaction sent successfully' : 'Failed to send transaction',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoadingTransfer = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _mintNFT(BuildContext context) async {
    final walletProvider = context.read<WalletProvider>();

    setState(() {
      _isLoadingMint = true;
    });

    try {
      final (success, hash) = await walletProvider.mintNFT();

      setState(() {
        _isLoadingMint = false;
        if (success && hash.isNotEmpty) {
          _mintTxHash = hash;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'NFT minted successfully' : 'Failed to mint NFT',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoadingMint = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}