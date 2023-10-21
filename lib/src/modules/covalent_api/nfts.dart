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
          .resolve('nft/${contractAddress.hex}/metadata/${tokenId.toString()}/')
          .path,
      {
        if (noMetadata) 'no-metadata': noMetadata.toString(),
        if (withUncached) 'with-uncached': withUncached.toString(),
      },
    ).then(
        (response) => NFT.fromMap((response['data']['items'] as List).first));
  }

  Future<List<NFT>> getNftsForOwner(
    EthereumAddress walletAddress, {
    bool noSpam = true,
    bool noNftAssetMetadata = false,
    bool withUncached = false,
  }) async {
    final response = await fetchApiRequest(
        baseCovalentApiUri
            .resolve('address/${walletAddress.hex}/balances_nft/')
            .path,
        {
          'no-spam': noSpam.toString(),
          if (noNftAssetMetadata)
            'no-nft-asset-metadata': noNftAssetMetadata.toString(),
          if (withUncached) 'with-uncached': withUncached.toString(),
        });

    return List<NFT>.from(
        (response['data']['items'] as List).map((x) => NFT.fromMap(x)));
  }
}

class NFT {
  final String? contractName;
  final String? contractTickerSymbol;
  final EthereumAddress contractAddress;
  final List<String>? supportsErc;
  final bool isSpam;
  final BigInt? balance;
  final BigInt? balance24H;
  final String type;
  final List<NFTData> nftData;
  final DateTime? lastTransferredAt;

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

  factory NFT.fromJson(String source) =>
      NFT.fromMap(json.decode(source) as Map<String, dynamic>);

  factory NFT.fromMap(Map<String, dynamic> map) {
    return NFT(
      contractName: map['contract_name'],
      contractTickerSymbol: map['contract_ticker_symbol'],
      contractAddress: EthereumAddress.fromHex(map['contract_address']),
      supportsErc: map['supports_erc'] != null
          ? List<String>.from(map['supports_erc'])
          : null,
      isSpam: map['is_spam'],
      balance: map['balance'] != null ? BigInt.parse(map['balance']) : null,
      balance24H:
          map['balance_24h'] != null ? BigInt.parse(map['balance_24h']) : null,
      type: map['type'],
      nftData: map['nft_data'] is List
          ? List<NFTData>.from(
              (map['nft_data'] as List).map((x) => NFTData.fromMap(x)))
          : [NFTData.fromMap(map['nft_data'])],
      lastTransferredAt: map['last_transfered_at'] != null
          ? DateTime.parse(map['last_transfered_at'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'contract_name': contractName,
      'contract_ticker_symbol': contractTickerSymbol,
      'contract_address': contractAddress.hex,
      'supports_erc': supportsErc,
      'is_spam': isSpam,
      'balance': balance.toString(),
      'balance_24h': balance24H.toString(),
      'type': type,
      'nft_data': nftData.map((x) => x.toMap()).toList(),
      'last_transfered_at': lastTransferredAt?.toIso8601String(),
    };
  }
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

  factory NFTData.fromJson(String source) =>
      NFTData.fromMap(json.decode(source) as Map<String, dynamic>);

  factory NFTData.fromMap(Map<String, dynamic> map) {
    return NFTData(
      tokenId: BigInt.parse(map['token_id']),
      tokenBalance: map['token_balance'],
      tokenUrl: map['token_url'],
      supportsErc: map['supports_erc'] != null
          ? List<String>.from(map['supports_erc'])
          : null,
      tokenPriceWei: map['token_price_wei'] != null
          ? BigInt.parse(map['token_price_wei'])
          : null,
      tokenQuoteRateEth: map['token_quote_rate_eth'],
      originalOwner: map['original_owner'] != null
          ? EthereumAddress.fromHex(map['original_owner'])
          : null,
      externalData: map['external_data'] != null
          ? NFTMetadata.fromMap(map['external_data'])
          : null,
      owner: map['owner'],
      ownerAddress: map['owner_address'] != null
          ? EthereumAddress.fromHex(map['owner_address'])
          : null,
      burned: map['burned'],
      assetCached: map['asset_cached'],
      imageCached: map['image_cached'],
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'token_id': tokenId.toString(),
      'token_balance': tokenBalance,
      'token_url': tokenUrl,
      'supports_erc': supportsErc,
      'token_price_wei': tokenPriceWei,
      'token_quote_rate_eth': tokenQuoteRateEth,
      'original_owner': originalOwner?.hex,
      'external_data': externalData?.toMap(),
      'owner': owner,
      'owner_address': ownerAddress?.hex,
      'burned': burned,
      'asset_cached': assetCached,
      'image_cached': imageCached,
    };
  }
}

class NFTMetadata {
  final String? name;
  final String? description;
  final String? assetUrl;
  final String? assetFileExtension;
  final String? assetMimeType;
  final String? assetSizeBytes;
  final String? image;
  final String? image256;
  final String? image512;
  final String? image1024;
  final String? animationUrl;
  final String? externalUrl;
  final Object? attributes;
  final String? owner;

  NFTMetadata({
    required this.name,
    required this.description,
    required this.assetUrl,
    required this.assetFileExtension,
    required this.assetMimeType,
    required this.assetSizeBytes,
    required this.image,
    required this.image256,
    required this.image512,
    required this.image1024,
    required this.animationUrl,
    required this.externalUrl,
    required this.attributes,
    required this.owner,
  });

  factory NFTMetadata.fromJson(String source) =>
      NFTMetadata.fromMap(json.decode(source) as Map<String, dynamic>);

  factory NFTMetadata.fromMap(Map<String, dynamic> map) {
    return NFTMetadata(
      name: map['name'],
      description: map['description'],
      assetUrl: map['asset_url'],
      assetFileExtension: map['asset_file_extension'],
      assetMimeType: map['asset_mime_type'],
      assetSizeBytes: map['asset_size_bytes'],
      image: map['image'],
      image256: map['image_256'],
      image512: map['image_512'],
      image1024: map['image_1024'],
      animationUrl: map['animation_url'],
      externalUrl: map['external_url'],
      attributes: map['attributes'],
      owner: map['owner'],
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'asset_url': assetUrl,
      'asset_file_extension': assetFileExtension,
      'asset_mime_type': assetMimeType,
      'asset_size_bytes': assetSizeBytes,
      'image': image,
      'image_256': image256,
      'image_512': image512,
      'image_1024': image1024,
      'animation_url': animationUrl,
      'external_url': externalUrl,
      'attributes': attributes,
      'owner': owner,
    };
  }
}
