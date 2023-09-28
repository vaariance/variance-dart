// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:typed_data';

import 'package:web3dart/web3dart.dart';

import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/4337/modules/contract.dart';
import 'package:pks_4337_sdk/src/4337/modules/contract_abis.dart';
import 'package:pks_4337_sdk/src/dio_client.dart';

/// uses alchemy nft api
/// if want to use another api, you have to create a custom class
class NFT {
  final Uri _baseNftApiUrl;

  final DioClient _dioClient = DioClient();

  NFT(String rpcUrl) : _baseNftApiUrl = Uri.parse(NFT.getBaseNftApiUrl(rpcUrl));

  static String getBaseNftApiUrl(String rpcUrl) {
    final sections = rpcUrl.split('/v2/');
    sections[1] = "/nft/v3/${sections[1]}";
    return sections.join('');
  }

  Future<Map<String, dynamic>> _fetchNftRequest(
      Map<String, Object?> queryParams, String path) async {
    final String requestUrl = _baseNftApiUrl
        .replace(path: path)
        .replace(queryParameters: queryParams)
        .toString();

    return await _dioClient.callNftApi<Map<String, dynamic>>(
      requestUrl,
    );
  }

  Future<NftResponse> getNftsForOwner(EthereumAddress address,
      {bool orderByTransferTime = false,
      bool withMetadata = true,
      String? pageKey}) async {
    final queryParams = {
      'owner': address.hex,
      'withMetadata': withMetadata,
      'orderBy': orderByTransferTime ? 'transferTime' : null,
    };

    if (pageKey != null) {
      queryParams['pageKey'] = pageKey;
    }

    final response = await _fetchNftRequest(queryParams, 'getOwnersForNFT');

    return NftResponse.fromMap(
        response,
        withMetadata
            ? ResponseType.withMetadata
            : ResponseType.withoutMetadata);
  }

  Future<NftMetadata> getNftMetadata(
      EthereumAddress contractAddress, Uint256 tokenId,
      {NftTokenType? type, bool refreshCache = false}) async {
    final queryParams = {
      'contractAddress': contractAddress.hex,
      'tokenId': tokenId.toInt(),
      'refreshCache': refreshCache,
    };
    if (type != null) {
      queryParams['tokenType'] = type.name.toUpperCase();
    }

    final response = await _fetchNftRequest(queryParams, 'getNFTMetadata');
    return NftMetadata.fromMap(response);
  }

  Future<bool> isSpamContract(EthereumAddress contractAddress) async {
    final response = await _fetchNftRequest(
        {'contractAddress': contractAddress.hex}, "isSpamContract");
    return response["isSpamContract"] as bool;
  }

  Future<bool> isAirdropNFT(
      EthereumAddress contractAddress, Uint256 tokenId) async {
    final response = await _fetchNftRequest(
        {'contractAddress': contractAddress.hex, 'tokenId': tokenId.toInt()},
        'isAirdropNFT');
    return response["isAirdrop"] as bool;
  }

  Future<NftPrice> getFloorPrice(EthereumAddress contractAddress) async {
    final response = await _fetchNftRequest(
        {'contractAddress': contractAddress.hex}, 'getFloorPrice');
    return NftPrice.fromMap(response);
  }

  Uint8List encodeERC721ApproveCall(
      EthereumAddress contractAddress, EthereumAddress to, Uint256 tokenId) {
    return Contract.encodeFunctionCall("approve", contractAddress,
        ContractAbis.get("ERC721"), [to.hex, tokenId.toHex()]);
  }

  Uint8List encodeERC721SafeTransferCall(EthereumAddress contractAddress,
      EthereumAddress from, EthereumAddress to, Uint256 tokenId) {
    return Contract.encodeFunctionCall("safeTransferFrom", contractAddress,
        ContractAbis.get("ERC721"), [from.hex, to.hex, tokenId.toHex()]);
  }
}

enum ResponseType { withMetadata, withoutMetadata }

enum NftTokenType { erc721, erc1155 }

class NftResponse {
  final List<NftMetadata>? _ownedNfts;
  final List<NftMetadataMinified>? _ownedNftsMinified;
  final String? pageKey;
  final int? totalCount;
  final ResponseType responseType;

  NftResponse({
    List<NftMetadata>? ownedNfts,
    List<NftMetadataMinified>? ownedNftsMinified,
    this.pageKey,
    this.totalCount,
    required this.responseType,
  })  : _ownedNftsMinified = ownedNftsMinified,
        _ownedNfts = ownedNfts;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ownedNfts': _ownedNfts?.map((x) => x.toMap()).toList(),
      'ownedNftsMinified': _ownedNftsMinified?.map((x) => x.toMap()).toList(),
      'pageKey': pageKey,
      'totalCount': totalCount,
      'responseType': responseType.name,
    };
  }

  T nftList<T>() {
    if (responseType == ResponseType.withMetadata) {
      require(T is NftMetadata, "generic doesn't match 'NftMetadata' type");
      return _ownedNfts as T;
    }
    require(T is NftMetadataMinified,
        "generic doesn't match 'NftMetadataMinified' type");
    return _ownedNftsMinified as T;
  }

  factory NftResponse.fromMap(
      Map<String, dynamic> map, ResponseType responseType) {
    return NftResponse(
      ownedNfts: responseType == ResponseType.withMetadata
          ? List<NftMetadata>.from(
              (map['ownedNfts'] as List<int>).map<NftMetadata?>(
                (x) => NftMetadata.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      ownedNftsMinified: responseType == ResponseType.withoutMetadata
          ? List<NftMetadataMinified>.from(
              (map['ownedNftsMinified'] as List<int>).map<NftMetadataMinified?>(
                (x) => NftMetadataMinified.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      pageKey: map['pageKey'] != null ? map['pageKey'] as String : null,
      totalCount: map['totalCount'] != null ? map['totalCount'] as int : null,
      responseType: responseType,
    );
  }

  String toJson() => json.encode(toMap());

  factory NftResponse.fromJson(String source, ResponseType responseType) =>
      NftResponse.fromMap(
          json.decode(source) as Map<String, dynamic>, responseType);
}

class NftMetadataMinified {
  final EthereumAddress contractAddress;
  final int tokenId;
  final int balance;

  NftMetadataMinified({
    required this.contractAddress,
    required this.tokenId,
    required this.balance,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'contractAddress': contractAddress.hex,
      'tokenId': tokenId,
      'balance': balance,
    };
  }

  factory NftMetadataMinified.fromMap(Map<String, dynamic> map) {
    return NftMetadataMinified(
      contractAddress:
          EthereumAddress.fromHex(map['contractAddress'] as String),
      tokenId: map['tokenId'] as int,
      balance: map['balance'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory NftMetadataMinified.fromJson(String source) =>
      NftMetadataMinified.fromMap(json.decode(source) as Map<String, dynamic>);
}

class NftMetadata {
  String address;
  String name;
  String symbol;
  int? totalSupply;
  String tokenType;
  bool isSpam;
  int tokenId;
  String tokenUri;
  OpenSeaMetadata? openSeaMetadata;
  Collection? collection;
  NftImages image;
  RawMetadata raw;
  int balance;
  DateTime? timeStamp;
  NftMetadata(
      {required this.address,
      required this.name,
      required this.symbol,
      this.totalSupply,
      required this.tokenType,
      required this.isSpam,
      required this.tokenId,
      required this.tokenUri,
      this.openSeaMetadata,
      this.collection,
      required this.image,
      required this.raw,
      required this.balance,
      this.timeStamp});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'address': address,
      'name': name,
      'symbol': symbol,
      'totalSupply': totalSupply,
      'tokenType': tokenType,
      'isSpam': isSpam,
      'tokenId': tokenId,
      'tokenUri': tokenUri,
      'openSeaMetadata': openSeaMetadata?.toMap(),
      'collection': collection?.toMap(),
      'image': image.toMap(),
      'raw': raw.toMap(),
      'balance': balance,
      'timeStamp': timeStamp?.toIso8601String(),
    };
  }

  factory NftMetadata.fromMap(Map<String, dynamic> map) {
    return NftMetadata(
      address: map['contract']['address'] as String,
      name: map['contract']['name'] as String,
      symbol: map['contract']['symbol'] as String,
      totalSupply:
          map['totalSupply'] != null ? map['totalSupply'] as int : null,
      tokenType: map['tokenType'] as String,
      isSpam: map['isSpam'] as bool,
      tokenId: map['tokenId'] as int,
      tokenUri: map['tokenUri'] as String,
      openSeaMetadata: map['openSeaMetadata'] != null
          ? OpenSeaMetadata.fromMap(
              map['openSeaMetadata'] as Map<String, dynamic>)
          : null,
      collection: map['collection'] != null
          ? Collection.fromMap(map['collection'] as Map<String, String>)
          : null,
      image: NftImages.fromMap(map['image'] as Map<String, dynamic>),
      raw: RawMetadata.fromMap(map['raw'] as Map<String, dynamic>),
      balance: map['balance'] as int,
      timeStamp: map['acquiredAt']['timeStamp'] != null
          ? DateTime.parse(map['acquiredAt']['timeStamp'])
          : null,
    );
  }
  String toJson() => json.encode(toMap());

  factory NftMetadata.fromJson(String source) =>
      NftMetadata.fromMap(json.decode(source) as Map<String, dynamic>);
}

class OpenSeaMetadata {
  int? floorPrice;
  String collectionName;
  String collectionSlug;
  String safelistRequestStatus;
  String imageUrl;
  String description;
  String externalUrl;
  String? twitterUsername;
  String? discordUrl;
  String bannerImageUrl;
  DateTime lastIngestedAt;

  OpenSeaMetadata({
    this.floorPrice,
    required this.collectionName,
    required this.collectionSlug,
    required this.safelistRequestStatus,
    required this.imageUrl,
    required this.description,
    required this.externalUrl,
    this.twitterUsername,
    this.discordUrl,
    required this.bannerImageUrl,
    required this.lastIngestedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'floorPrice': floorPrice,
      'collectionName': collectionName,
      'collectionSlug': collectionSlug,
      'safelistRequestStatus': safelistRequestStatus,
      'imageUrl': imageUrl,
      'description': description,
      'externalUrl': externalUrl,
      'twitterUsername': twitterUsername,
      'discordUrl': discordUrl,
      'bannerImageUrl': bannerImageUrl,
      'lastIngestedAt': lastIngestedAt.toIso8601String(),
    };
  }

  factory OpenSeaMetadata.fromMap(Map<String, dynamic> map) {
    return OpenSeaMetadata(
      floorPrice: map['floorPrice'] != null ? map['floorPrice'] as int : null,
      collectionName: map['collectionName'] as String,
      collectionSlug: map['collectionSlug'] as String,
      safelistRequestStatus: map['safelistRequestStatus'] as String,
      imageUrl: map['imageUrl'] as String,
      description: map['description'] as String,
      externalUrl: map['externalUrl'] as String,
      twitterUsername: map['twitterUsername'] != null
          ? map['twitterUsername'] as String
          : null,
      discordUrl:
          map['discordUrl'] != null ? map['discordUrl'] as String : null,
      bannerImageUrl: map['bannerImageUrl'] as String,
      lastIngestedAt:
          DateTime.parse(map['lastIngestedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory OpenSeaMetadata.fromJson(String source) =>
      OpenSeaMetadata.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Collection {
  String name;
  String slug;
  String externalUrl;
  String bannerImageUrl;

  Collection({
    required this.name,
    required this.slug,
    required this.externalUrl,
    required this.bannerImageUrl,
  });

  Map<String, dynamic> toMap() {
    return <String, String>{
      'name': name,
      'slug': slug,
      'externalUrl': externalUrl,
      'bannerImageUrl': bannerImageUrl,
    };
  }

  factory Collection.fromMap(Map<String, String> map) {
    return Collection(
      name: map['name'] as String,
      slug: map['slug'] as String,
      externalUrl: map['externalUrl'] as String,
      bannerImageUrl: map['bannerImageUrl'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Collection.fromJson(String source) =>
      Collection.fromMap(json.decode(source) as Map<String, String>);
}

class NftImages {
  String? cachedUrl;
  String? thumbnailUrl;
  String? pngUrl;
  String? contentType;
  int? size;
  String? originalUrl;

  NftImages({
    this.cachedUrl,
    this.thumbnailUrl,
    this.pngUrl,
    this.contentType,
    this.size,
    this.originalUrl,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cachedUrl': cachedUrl,
      'thumbnailUrl': thumbnailUrl,
      'pngUrl': pngUrl,
      'contentType': contentType,
      'size': size,
      'originalUrl': originalUrl,
    };
  }

  factory NftImages.fromMap(Map<String, dynamic> map) {
    return NftImages(
      cachedUrl: map['cachedUrl'] != null ? map['cachedUrl'] as String : null,
      thumbnailUrl:
          map['thumbnailUrl'] != null ? map['thumbnailUrl'] as String : null,
      pngUrl: map['pngUrl'] != null ? map['pngUrl'] as String : null,
      contentType:
          map['contentType'] != null ? map['contentType'] as String : null,
      size: map['size'] != null ? map['size'] as int : null,
      originalUrl:
          map['originalUrl'] != null ? map['originalUrl'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory NftImages.fromJson(String source) =>
      NftImages.fromMap(json.decode(source) as Map<String, dynamic>);
}

class NftPrice {
  final NftFloorPrice openSea;
  final NftFloorPrice looksRare;

  NftPrice({
    required this.openSea,
    required this.looksRare,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'openSea': openSea.toMap(),
      'looksRare': looksRare.toMap(),
    };
  }

  factory NftPrice.fromMap(Map<String, dynamic> map) {
    return NftPrice(
      openSea: NftFloorPrice.fromMap(map['openSea'] as Map<String, dynamic>),
      looksRare:
          NftFloorPrice.fromMap(map['looksRare'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory NftPrice.fromJson(String source) =>
      NftPrice.fromMap(json.decode(source) as Map<String, dynamic>);
}

class NftFloorPrice {
  double floorPrice;
  String priceCurrency;
  String collectionUrl;
  DateTime retrievedAt;
  dynamic error;

  NftFloorPrice({
    required this.floorPrice,
    required this.priceCurrency,
    required this.collectionUrl,
    required this.retrievedAt,
    required this.error,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'floorPrice': floorPrice,
      'priceCurrency': priceCurrency,
      'collectionUrl': collectionUrl,
      'retrievedAt': retrievedAt.toIso8601String(),
      'error': error,
    };
  }

  factory NftFloorPrice.fromMap(Map<String, dynamic> map) {
    return NftFloorPrice(
      floorPrice: map['floorPrice'] as double,
      priceCurrency: map['priceCurrency'] as String,
      collectionUrl: map['collectionUrl'] as String,
      retrievedAt:
          DateTime.parse(map['retrievedAt']),
      error: map['error'] as dynamic,
    );
  }

  String toJson() => json.encode(toMap());

  factory NftFloorPrice.fromJson(String source) =>
      NftFloorPrice.fromMap(json.decode(source) as Map<String, dynamic>);
}

class RawMetadata {
  final String tokenUri;
  final Metadata? metadata;
  final String? error;

  RawMetadata({
    required this.tokenUri,
    this.metadata,
    this.error,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tokenUri': tokenUri,
      'metadata': metadata?.toMap(),
      'error': error,
    };
  }

  factory RawMetadata.fromMap(Map<String, dynamic> map) {
    return RawMetadata(
      tokenUri: map['tokenUri'] as String,
      metadata: map['metadata'] != null
          ? Metadata.fromMap(map['metadata'] as Map<String, dynamic>)
          : null,
      error: map['error'] != null ? map['error'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory RawMetadata.fromJson(String source) =>
      RawMetadata.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Metadata {
  final String? name;
  final String? image;
  final List<Map<String, dynamic>>? attributes;

  Metadata({
    this.name,
    this.image,
    this.attributes,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'image': image,
      'attributes': attributes,
    };
  }

  factory Metadata.fromMap(Map<String, dynamic> map) {
    return Metadata(
      name: map['name'] != null ? map['name'] as String : null,
      image: map['image'] != null ? map['image'] as String : null,
      attributes: map['attributes'] != null
          ? List<Map<String, dynamic>>.from(
              (map['attributes'] as List<dynamic>).map<Map<String, dynamic>?>(
                (x) => x,
              ),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Metadata.fromJson(String source) =>
      Metadata.fromMap(json.decode(source) as Map<String, dynamic>);
}
