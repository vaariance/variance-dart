import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/4337/modules/alchemyApi/erc20.dart';
import 'package:pks_4337_sdk/src/4337/modules/alchemyApi/transfers.dart';
import 'package:pks_4337_sdk/src/4337/modules/alchemyApi/utils/enum.dart';
import 'package:pks_4337_sdk/src/4337/modules/contract.dart';
import 'package:pks_4337_sdk/src/abi/abis.dart';
import 'package:web3dart/crypto.dart';
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

late BaseProvider provider;

// final erc20Address =
//     EthereumAddress.fromHex('0xe785E82358879F061BC3dcAC6f0444462D4b5330');
// final spender =
//     EthereumAddress.fromHex('0xf1a726210550c306a9964b251cbcd3fa5ecb275d');
// final owner =
//     EthereumAddress.fromHex('0xdef1c0ded9bec7f1a1670819833240f027b25eff');
// final contractAddress =
//     EthereumAddress.fromHex('0xe785E82358879F061BC3dcAC6f0444462D4b5330');
class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    const rpcUrl =
        'https://eth-mainnet.g.alchemy.com/v2/cLTpHWqs6iaOgFrnuxMVl9Z1Ung00otf';

    provider = BaseProvider(rpcUrl);
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

          final contractAddress = EthereumAddress.fromHex(
              "0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270");
          final tokenId = BigInt.from(44);

          final transfersInstance = Transfers(provider);
          final newInst = await transfersInstance.getTransfersByCategory(
            owner,
            [TransferCategory.erc721],
          );
          log('newInst: ${newInst.transfers.map((e) => e.toMap())}');
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
