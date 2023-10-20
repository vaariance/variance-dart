import 'dart:developer' as dev;
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pks_4337_sdk/pks_4337_sdk.dart' as wlt;
import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/modules/covalent_api/covalent_api.dart';
import 'package:pks_4337_sdk/src/signer/credential_key.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //late final BaseProvider baseProvider;
  wlt.Wallet wallet = wlt.Wallet(
      signer: wlt.SignerType.credential,
      credential: CredentialKey.createRandom("12345678"),
      chain: Chains.getChain(Chain.localhost));

  @override
  void initState() {
    // baseProvider = BaseProvider(wallet.walletChain.rpcUrl!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final nonEns = EthereumAddress.fromHex(
              "0xE1baa8F32Ac4Aa03031bbD6B6a970ab1892195ee");
          final withEns = EthereumAddress.fromHex(
              "0x104EDD9708fFeeCd0b6bAaA37387E155Bce7d060");

          final owner = EthereumAddress.fromHex(
              "0x5c43B1eD97e52d009611D89b74fA829FE4ac56b1");
          final spender = EthereumAddress.fromHex(
              "0xdef1c0ded9bec7f1a1670819833240f027b25eff");
          final tokenContract = EthereumAddress.fromHex(
              "0xdAC17F958D2ee523a2206206994597C13D831ec7");

          final vitalik = await EthereumAddress.fromHex(
              "0xd8da6bf26964af9d7eed9e03e53415d37aa96045");

          final contractAddress = EthereumAddress.fromHex(
              "0xe785E82358879F061BC3dcAC6f0444462D4b5330");
          final tokenId = BigInt.from(44);
          const apiKey = 'cqt_rQxhPTkKmPYMYtYTYB9fCFTgrrY7';

          log("address: ${wallet.toHex}, deployed: ${await wallet.deployed}, balance: ${(await wallet.balance).getInEther}, nonce: ${(await wallet.nonce).toInt()} rpc: ${wallet.walletChain.rpcUrl} bundlerUri: ${wallet.walletChain.bundlerUrl}");
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
// Future userOptester() async {
//   final uop = UserOperation(
//     "0x3AcF7270a4e8D1d1b0656aA76E50C28a40446e77",
//     BigInt.from(2),
//     '0x',
//     '0xb61d27f60000000000000000000000003acf7270a4e8d1d1b0656aa76e50c28a40446e77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000004b0d691fe00000000000000000000000000000000000000000000000000000000',
//     BigInt.from(55000),
//     BigInt.from(80000),
//     BigInt.from(51000),
//     BigInt.zero,
//     BigInt.zero,
//     '0x065f98b3a6250d7a2ba16af1d9cd70e7399dfdd43a59b066fad919c0b0091d8a0ae13b9ee0dc11576f89fb86becac6febf1ea859cb5dad5f3aac3d024eb77f681c',
//     '0x',
//   ).toMap();

//   final etp = await walletProvider.getUserOpReceipt(
//       "0x968330a7d22692ee1214512ee474de65ff00d246440978de87e5740d09d2d354");
//   log("etp: ${etp.toString()}");
//   // walletProvider.sendUserOperation(et, entryPoint)
// }