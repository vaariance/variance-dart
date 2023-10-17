import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/modules/alchemy_api/alchemy_api.dart';
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

          final vitalik = await Address.fromEns("vitalik.eth");

          final contractAddress = EthereumAddress.fromHex(
              "0xe785E82358879F061BC3dcAC6f0444462D4b5330");
          final tokenId = BigInt.from(44);

          final erc721 = AlchemyNftApi(provider.rpcUrl);
          final floorPrice = await erc721.isSpamContract(contractAddress);
          log("floorPrice.toMap(): $floorPrice");
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

final jso = {
  "contract": {
    "address": "0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85",
    "name": null,
    "symbol": null,
    "totalSupply": null,
    "tokenType": "ERC721",
    "contractDeployer": "0x4Fe4e666Be5752f1FdD210F4Ab5DE2Cc26e3E0e8",
    "deployedBlockNumber": 9380410,
    "openSeaMetadata": {
      "floorPrice": 0.001,
      "collectionName": "ENS: Ethereum Name Service",
      "collectionSlug": "ens",
      "safelistRequestStatus": "verified",
      "imageUrl":
          "https://i.seadn.io/gae/0cOqWoYA7xL9CkUjGlxsjreSYBdrUBE0c6EO1COG4XE8UeP-Z30ckqUNiL872zHQHQU5MUNMNhfDpyXIP17hRSC5HQ?w=500&auto=format",
      "description":
          "Ethereum Name Service (ENS) domains are secure domain names for the decentralized world. ENS domains provide a way for users to map human readable names to blockchain and non-blockchain resources, like Ethereum addresses, IPFS hashes, or website URLs. ENS domains can be bought and sold on secondary markets.",
      "externalUrl": "https://ens.domains",
      "twitterUsername": "ensdomains",
      "discordUrl": null,
      "bannerImageUrl": null,
      "lastIngestedAt": "2023-09-28T12:44:04.000Z"
    },
    "isSpam": null,
    "spamClassifications": []
  },
  "tokenId":
      "97933994528983981932140373425026813989633204432494122706027085917658427161521",
  "tokenType": "ERC721",
  "name": "anyaogu.eth",
  "description": "anyaogu.eth, an ENS name.",
  "tokenUri":
      "https://metadata.ens.domains/mainnet/0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85/0xd884ad34aed63e9bdb2836664fd230370ff05499a93a14ba504ab364bd47fbb1",
  "image": {
    "cachedUrl":
        "https://nft-cdn.alchemy.com/eth-mainnet/3361e0a3600632154bc5a2f96ede75f2",
    "thumbnailUrl": null,
    "pngUrl":
        "https://res.cloudinary.com/alchemyapi/image/upload/convert-png/eth-mainnet/3361e0a3600632154bc5a2f96ede75f2",
    "contentType": "image/svg+xml",
    "size": null,
    "originalUrl":
        "https://metadata.ens.domains/mainnet/0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85/0xd884ad34aed63e9bdb2836664fd230370ff05499a93a14ba504ab364bd47fbb1/image"
  },
  "raw": {
    "tokenUri":
        "https://metadata.ens.domains/mainnet/0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85/0xd884ad34aed63e9bdb2836664fd230370ff05499a93a14ba504ab364bd47fbb1",
    "metadata": {
      "background_image":
          "https://metadata.ens.domains/mainnet/avatar/anyaogu.eth",
      "image":
          "https://metadata.ens.domains/mainnet/0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85/0xd884ad34aed63e9bdb2836664fd230370ff05499a93a14ba504ab364bd47fbb1/image",
      "last_request_date": 1696529385578,
      "is_normalized": true,
      "image_url":
          "https://metadata.ens.domains/mainnet/0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85/0xd884ad34aed63e9bdb2836664fd230370ff05499a93a14ba504ab364bd47fbb1/image",
      "name": "anyaogu.eth",
      "description": "anyaogu.eth, an ENS name.",
      "attributes": [
        {
          "display_type": "date",
          "value": 1665138539000,
          "trait_type": "Created Date"
        },
        {"display_type": "number", "value": 7, "trait_type": "Length"},
        {"display_type": "number", "value": 7, "trait_type": "Segment Length"},
        {
          "display_type": "string",
          "value": "letter",
          "trait_type": "Character Set"
        },
        {
          "display_type": "date",
          "value": 1665138539000,
          "trait_type": "Registration Date"
        },
        {
          "display_type": "date",
          "value": 1759767491000,
          "trait_type": "Expiration Date"
        }
      ],
      "version": 0,
      "url": "https://app.ens.domains/name/anyaogu.eth"
    },
    "error": null
  },
  "collection": {
    "name": "ENS: Ethereum Name Service",
    "slug": "ens",
    "externalUrl": "https://ens.domains",
    "bannerImageUrl": null
  },
  "mint": {
    "mintAddress": null,
    "blockNumber": null,
    "timestamp": null,
    "transactionHash": null
  },
  "owners": null,
  "timeLastUpdated": "2023-10-05T18:31:01.640Z",
  "balance": 1,
  "acquiredAt": {"blockTimestamp": null, "blockNumber": null}
};
