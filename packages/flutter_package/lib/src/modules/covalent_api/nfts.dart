// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:pks_4337_sdk/src/modules/covalent_api/covalent_api.dart';
import 'package:web3dart/web3dart.dart';

class CovalentNftApi extends BaseCovalentApi {
  CovalentNftApi(
    super._apiKey,
    super.chainName,
  );

  Future<NFT> getNftMetadata(
    EthereumAddress contractAddress,
    BigInt tokenId, {
    bool noMetadata = false,
    bool withUncached = false,
  }) {
    return fetchApiRequest(
      baseCovalentApiUri
          .resolve('tokens/${contractAddress.hex}/${tokenId.toString()}')
          .path,
      {
        'no-metadata': noMetadata,
        if (withUncached) 'with-uncached': withUncached,
      },
    ).then((response) => NFT.fromMap((response['items'] as List).first));
  }

  Future<List<NFT>> getNftsForOwner(
    EthereumAddress walletAddress, {
    bool noSpam = true,
    bool noNftAssetMetadata = false,
    bool withUncached = false,
  }) async {
    final response = await fetchApiRequest(
        baseCovalentApiUri
            .resolve('address/${walletAddress.hex}/balances_nft')
            .path,
        {
          'no-spam': noSpam,
          if (noNftAssetMetadata) 'no-nft-asset-metadata': noNftAssetMetadata,
          if (withUncached) 'with-uncached': withUncached,
        });

    return List<NFT>.from(
        (response['items'] as List).map((x) => NFT.fromMap(x)));
  }
}

class NFT {
  final String contractName;
  final String contractTickerSymbol;
  final EthereumAddress contractAddress;
  final List<String> supportsErc;
  final bool isSpam;
  final int balance;
  final int balance24H;
  final String type;
  final List<NFTData> nftData;
  final DateTime lastTransferredAt;

  NFT({
    required this.contractName,
    required this.contractTickerSymbol,
    required this.contractAddress,
    required this.supportsErc,
    required this.isSpam,
    required this.balance,
    required this.balance24H,
    required this.type,
    required this.nftData,
    required this.lastTransferredAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'contractName': contractName,
      'contractTickerSymbol': contractTickerSymbol,
      'contractAddress': contractAddress.hex,
      'supportsErc': supportsErc,
      'isSpam': isSpam,
      'balance': balance,
      'balance24H': balance24H,
      'type': type,
      'nftData': nftData.map((x) => x.toMap()).toList(),
      'lastTransferredAt': lastTransferredAt.toIso8601String(),
    };
  }

  factory NFT.fromMap(Map<String, dynamic> map) {
    return NFT(
      contractName: map['contractName'],
      contractTickerSymbol: map['contractTickerSymbol'],
      contractAddress: EthereumAddress.fromHex(map['contractAddress']),
      supportsErc: List<String>.from(map['supportsErc']),
      isSpam: map['isSpam'],
      balance: map['balance'],
      balance24H: map['balance24H'],
      type: map['type'],
      nftData: List<NFTData>.from(
        (map['nftData']).map<NFTData?>(
          (x) => NFTData.fromMap(x),
        ),
      ),
      lastTransferredAt: DateTime.parse(map['lastTransferredAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory NFT.fromJson(String source) =>
      NFT.fromMap(json.decode(source) as Map<String, dynamic>);
}

class NFTData {
  final BigInt tokenId;
  final String? tokenBalance;
  final String? tokenUrl;
  final List<String>? supportsErc;
  final BigInt? tokenPriceWei;
  final num? tokenQuoteRateEth;
  final EthereumAddress? originalOwner;
  final NFTMetadata? externalData;
  final String? owner;
  final EthereumAddress? ownerAddress;
  final bool? burned;
  final bool? assetCached;
  final bool? imageCached;

  NFTData(
      {required this.tokenId,
      this.tokenBalance,
      required this.tokenUrl,
      this.supportsErc,
      this.tokenPriceWei,
      this.tokenQuoteRateEth,
      required this.originalOwner,
      required this.externalData,
      this.owner,
      this.ownerAddress,
      this.burned,
      this.assetCached,
      this.imageCached});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tokenId': tokenId.toString(),
      'tokenBalance': tokenBalance,
      'tokenUrl': tokenUrl,
      'supportsErc': supportsErc,
      'tokenPriceWei': tokenPriceWei,
      'tokenQuoteRateEth': tokenQuoteRateEth,
      'originalOwner': originalOwner?.hex,
      'externalData': externalData?.toMap(),
      'owner': owner,
      'ownerAddress': ownerAddress?.hex,
      'burned': burned,
      'assetCached': assetCached,
      'imageCached': imageCached,
    };
  }

  factory NFTData.fromMap(Map<String, dynamic> map) {
    return NFTData(
      tokenId: BigInt.parse(map['tokenId']),
      tokenBalance: map['tokenBalance'],
      tokenUrl: map['tokenUrl'],
      supportsErc: map['supportsErc'] != null
          ? List<String>.from(map['supportsErc'])
          : null,
      tokenPriceWei: map['tokenPriceWei'] != null
          ? BigInt.parse(map['tokenPriceWei'])
          : null,
      tokenQuoteRateEth: map['tokenQuoteRateEth'] != null
          ? map['tokenQuoteRateEth'] as num
          : null,
      originalOwner: map['originalOwner'] != null
          ? EthereumAddress.fromHex(map['originalOwner'])
          : null,
      externalData: map['externalData'] != null
          ? NFTMetadata.fromMap(map['externalData'])
          : null,
      owner: map['owner'],
      ownerAddress: map['ownerAddress'] != null
          ? EthereumAddress.fromHex(map['ownerAddress'])
          : null,
      burned: map['burned'] != null ? map['burned'] as bool : null,
      assetCached:
          map['assetCached'] != null ? map['assetCached'] as bool : null,
      imageCached:
          map['imageCached'] != null ? map['imageCached'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory NFTData.fromJson(String source) =>
      NFTData.fromMap(json.decode(source) as Map<String, dynamic>);
}

class NFTMetadata {
  final String name;
  final String description;
  final String image;
  final String image256;
  final String image512;
  final String image1024;
  final String? animationUrl;
  final String externalUrl;
  final Object? attributes;
  final String? owner;

  NFTMetadata({
    required this.name,
    required this.description,
    required this.image,
    required this.image256,
    required this.image512,
    required this.image1024,
    required this.animationUrl,
    required this.externalUrl,
    required this.attributes,
    required this.owner,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'image': image,
      'image256': image256,
      'image512': image512,
      'image1024': image1024,
      'animationUrl': animationUrl,
      'externalUrl': externalUrl,
      'attributes': attributes,
      'owner': owner,
    };
  }

  factory NFTMetadata.fromMap(Map<String, dynamic> map) {
    return NFTMetadata(
      name: map['name'],
      description: map['description'],
      image: map['image'],
      image256: map['image256'],
      image512: map['image512'],
      image1024: map['image1024'],
      animationUrl: map['animationUrl'],
      externalUrl: map['externalUrl'],
      attributes: map['attributes'],
      owner: map['owner'],
    );
  }

  String toJson() => json.encode(toMap());

  factory NFTMetadata.fromJson(String source) =>
      NFTMetadata.fromMap(json.decode(source) as Map<String, dynamic>);
}
