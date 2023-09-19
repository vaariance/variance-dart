library passkeysafe;

import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectOptions {
  final String projectId;
  final String name;
  final String description;
  final String url;
  final String logUrl;
  WalletConnectOptions({
    required this.projectId,
    required this.name,
    required this.description,
    required this.url,
    required this.logUrl,
  });
}

class WalletExpose {
  final WalletConnectOptions _opts;
  // ignore: unused_field
  late Web3Wallet _web3Wallet;

  WalletExpose({required WalletConnectOptions opts}) : _opts = opts {
    _createInstance();
  }

  Future _createInstance() async {
    _web3Wallet = await Web3Wallet.createInstance(
      // The relay websocket URL, leave blank to use the default
      relayUrl:
          'wss://relay.walletconnect.com', 
      projectId: _opts.projectId,
      metadata: PairingMetadata(
          name: _opts.name,
          description: _opts.description,
          url: _opts.url,
          icons: [_opts.logUrl]),
    );
  }
}
