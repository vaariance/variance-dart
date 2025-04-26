import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:variancedemo/providers/wallet_provider.dart';
import 'package:variancedemo/screens/home/home_widgets.dart';
import 'package:variancedemo/screens/widgets/modular_action_card.dart';

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.select(
      (WalletProvider provider) => provider,
    );

    final wallet = provider.wallet;

    bool isFromModularAccounts = wallet?.is7579Enabled ?? false;

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        body: SafeArea(
          child: SingleChildScrollView(
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
                                width:
                                    double.infinity, // Makes button fill width
                                height: 45,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoadingTransfer
                                      ? null
                                      : () async {
                                          setState(() {
                                            _isLoadingTransfer = true;
                                          });
                                          final (success, res) =
                                              await provider.simulateTransfer();
                                          if (success) {
                                            setState(() {
                                              _mintTxHash = res;
                                            });
                                          } else {
                                            // Handle error
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Transfer failed: $res'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                          setState(() {
                                            _isLoadingTransfer = false;
                                          });
                                        },
                                  icon: _isLoadingTransfer
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
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
                                width:
                                    double.infinity, // Makes button fill width
                                height: 45,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoadingMint
                                      ? null
                                      : () async {
                                          setState(() {
                                            _isLoadingMint = true;
                                          });
                                          final (success, res) =
                                              await provider.simulateMint();
                                          if (success) {
                                            setState(() {
                                              _mintTxHash = res;
                                            });
                                          } else {
                                            // Handle error
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Minting failed: $res'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                          setState(() {
                                            _isLoadingMint = false;
                                          });
                                        },
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_transferTxHash.isNotEmpty || _mintTxHash.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _transferTxHash.isNotEmpty
                                        ? _transferTxHash
                                        : _mintTxHash,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                        color: Colors.greenAccent),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 16),
                                  color: Colors.lightGreen,
                                  onPressed: () => _copyToClipboard(
                                    _transferTxHash.isNotEmpty
                                        ? _transferTxHash
                                        : _mintTxHash,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),
                  if (isFromModularAccounts) ...[
                    const Padding(
                      padding: EdgeInsets.all(0.0),
                      child: ModularActionsCard(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ));
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
