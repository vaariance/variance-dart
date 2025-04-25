import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:variancedemo/providers/wallet_provider.dart';
import 'package:variancedemo/screens/home/home_widgets.dart';
import 'package:variancedemo/screens/widgets/modular_action_card.dart';
import '../../models/modular_account_impl.dart';

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
  late Home7579InterfaceImpl _accountInterface;

  @override
  void initState() {
    super.initState();
    _accountInterface = Home7579InterfaceImpl();
  }

  @override
  Widget build(BuildContext context) {
    // !! fix :  @maxiggle i need to verify if this is the cause of the problem
    final walletProvider = context.watch<WalletProvider>();

    bool isFromModularAccounts = walletProvider.wallet?.is7579Enabled ?? false;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        title: const Text('Wallet Home'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/create-account');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WalletBalance(),
              const Center(child: Receive()),
              const SizedBox(height: 24),

              // ERC20 Transfer Action
              Row(
                children: [
                  Expanded(
                    flex: 1, // Ensures 50% width
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity, // Makes button fill width
                            child: ElevatedButton.icon(
                              //? todo :  @maxiggle i need to call the simulate transfer from the provider here
                              onPressed: _isLoadingTransfer ? null : () {},
                              icon: _isLoadingTransfer
                                  ? const SizedBox(
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF663399),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.send,
                                      color: Color(0xFF663399),
                                      size: 16,
                                    ),
                              label: Text(
                                _isLoadingTransfer
                                    ? 'Sending...'
                                    : 'Simulte Transfer',
                                style: TextStyle(
                                  color: Colors.grey[200],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2A2A3C),
                                foregroundColor: Colors.grey[200],
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                      color: const Color(0xFF663399)
                                          .withOpacity(0.3),
                                      width: 2),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          if (_transferTxHash.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
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
                                          icon:
                                              const Icon(Icons.copy, size: 16),
                                          onPressed: () =>
                                              _copyToClipboard(_transferTxHash),
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
                    ),
                  ),
                  Expanded(
                    flex: 1, // Ensures 50% width
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity, // Makes button fill width
                            child: ElevatedButton.icon(
                              //? todo :  @maxiggle i need to call the simulate mint from the provider here
                              onPressed: _isLoadingMint ? null : () {},
                              icon: _isLoadingMint
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF663399),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.image,
                                      color: Color(0xFF663399),
                                      size: 16,
                                    ),
                              label: Text(
                                _isLoadingMint ? 'Minting...' : 'Mint NFT',
                                style: TextStyle(
                                  color: Colors.grey[200],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2A2A3C),
                                foregroundColor: Colors.grey[200],
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                      color: const Color(0xFF663399)
                                          .withOpacity(0.3),
                                      width: 2),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          if (_mintTxHash.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
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
                                          icon:
                                              const Icon(Icons.copy, size: 16),
                                          onPressed: () =>
                                              _copyToClipboard(_mintTxHash),
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
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (isFromModularAccounts) ...[
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child:
                      ModularActionsCard(accountInterface: _accountInterface),
                ),
              ],
            ],
          ),
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
}
