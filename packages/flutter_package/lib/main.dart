import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:pks_4337_sdk/src/modules/covalent_api/covalent_api.dart';
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
  @override
  void initState() {
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

          final txs = CovalentTransactionsApi(apiKey, 'eth-mainnet');
          dev.log("first message");
          print(
              "token: ${(await txs.getTokenTransfersByContract(vitalik, contractAddress: EthereumAddress.fromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"))).transaction.first.toJson()}");
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
