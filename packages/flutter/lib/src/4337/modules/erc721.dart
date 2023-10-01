import 'dart:convert';

import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/4337/modules/contract.dart';
import 'package:pks_4337_sdk/src/4337/modules/enum.dart';
import 'package:pks_4337_sdk/src/4337/modules/metadatas.dart';
import 'package:pks_4337_sdk/src/abi/abis.dart';
import 'package:pks_4337_sdk/src/dio_client.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

/// uses alchemy nft api
/// if want to use another api, you have to create a custom class
class ERC721 {
  final Uri _baseNftApiUrl;

  final DioClient _dioClient = DioClient();

  ERC721(String rpcUrl)
      : _baseNftApiUrl = Uri.parse(ERC721.getBaseNftApiUrl(rpcUrl));

  Future<NFTPrice> getFloorPrice(EthereumAddress contractAddress) async {
    final response = await _fetchNftRequest(
        {'contractAddress': contractAddress.hex}, 'getFloorPrice');
    return NFTPrice.fromMap(response);
  }

  Future<NFTMetadata> getNftMetadata(
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
    return NFTMetadata.fromMap(response);
  }

  Future<NFTQueryResponse> getNftsForOwner(EthereumAddress address,
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

    return NFTQueryResponse.fromMap(
        response,
        withMetadata
            ? ResponseType.withMetadata
            : ResponseType.withoutMetadata);
  }

  Future<bool> isAirdropNFT(
      EthereumAddress contractAddress, Uint256 tokenId) async {
    final response = await _fetchNftRequest(
        {'contractAddress': contractAddress.hex, 'tokenId': tokenId.toInt()},
        'isAirdropNFT');
    return response["isAirdrop"] as bool;
  }

  Future<bool> isSpamContract(EthereumAddress contractAddress) async {
    final response = await _fetchNftRequest(
        {'contractAddress': contractAddress.hex}, "isSpamContract");
    return response["isSpamContract"] as bool;
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

  static String encodeERC721ApproveCall(
      EthereumAddress contractAddress, EthereumAddress to, Uint256 tokenId) {
    return bytesToHex(
        Contract.encodeFunctionCall("approve", contractAddress,
            ContractAbis.get("ERC721"), [to.hex, tokenId.value]),
        include0x: true,
        padToEvenLength: true);
  }

  static String encodeERC721SafeTransferCall(EthereumAddress contractAddress,
      EthereumAddress from, EthereumAddress to, Uint256 tokenId) {
    return bytesToHex(
        Contract.encodeFunctionCall("safeTransferFrom", contractAddress,
            ContractAbis.get("ERC721"), [from.hex, to.hex, tokenId.value]),
        include0x: true,
        padToEvenLength: true);
  }

  static String getBaseNftApiUrl(String rpcUrl) {
    final sections = rpcUrl.split('/v2/');
    sections[1] = "/nft/v3/${sections[1]}";
    return sections.join('');
  }
}

class NFT {
  final EthereumAddress address;
  final int tokenId;
  final int balance;
  final NFTMetadata? metadata;

  NFT(
      {required this.address,
      required this.tokenId,
      required this.balance,
      this.metadata});

  factory NFT.fromJson(String source, ResponseType responseType) =>
      NFT.fromMap(json.decode(source) as Map<String, dynamic>, responseType);

  factory NFT.fromMap(Map<String, dynamic> map, ResponseType responseType) {
    return NFT(
      address: EthereumAddress.fromHex(map['contractAddress'] as String),
      tokenId: map['tokenId'] as int,
      balance: map['balance'] as int,
      metadata: responseType == ResponseType.withMetadata
          ? NFTMetadata.fromMap(map)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'contractAddress': address.hex,
      'tokenId': tokenId,
      'balance': balance,
      'metadata': metadata?.toMap(),
    };
  }

  Future approveNFT(NFT nft, EthereumAddress spender) async {
    // approves nft via syntactic sugar
  }

  Future transferNFT(NFT nft, EthereumAddress recipient) async {
    // sends a nft via syntactic sugar
  }
}

class NFTFloorPrice {
  double floorPrice;
  String priceCurrency;
  String collectionUrl;
  DateTime retrievedAt;
  dynamic error;

  NFTFloorPrice({
    required this.floorPrice,
    required this.priceCurrency,
    required this.collectionUrl,
    required this.retrievedAt,
    required this.error,
  });

  factory NFTFloorPrice.fromJson(String source) =>
      NFTFloorPrice.fromMap(json.decode(source) as Map<String, dynamic>);

  factory NFTFloorPrice.fromMap(Map<String, dynamic> map) {
    return NFTFloorPrice(
      floorPrice: map['floorPrice'] as double,
      priceCurrency: map['priceCurrency'] as String,
      collectionUrl: map['collectionUrl'] as String,
      retrievedAt: DateTime.parse(map['retrievedAt']),
      error: map['error'] as dynamic,
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'floorPrice': floorPrice,
      'priceCurrency': priceCurrency,
      'collectionUrl': collectionUrl,
      'retrievedAt': retrievedAt.toIso8601String(),
      'error': error,
    };
  }
}

class NFTMetadata {
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
  NFTUris image;
  RawMetadata raw;
  int balance;
  DateTime? timeStamp;
  NFTMetadata(
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

  factory NFTMetadata.fromJson(String source) =>
      NFTMetadata.fromMap(json.decode(source) as Map<String, dynamic>);

  factory NFTMetadata.fromMap(Map<String, dynamic> map) {
    return NFTMetadata(
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
      image: NFTUris.fromMap(map['image'] as Map<String, dynamic>),
      raw: RawMetadata.fromMap(map['raw'] as Map<String, dynamic>),
      balance: map['balance'] as int,
      timeStamp: map['acquiredAt']['timeStamp'] != null
          ? DateTime.parse(map['acquiredAt']['timeStamp'])
          : null,
    );
  }
  String toJson() => json.encode(toMap());

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
}

class NFTPrice {
  final NFTFloorPrice openSea;
  final NFTFloorPrice looksRare;

  NFTPrice({
    required this.openSea,
    required this.looksRare,
  });

  factory NFTPrice.fromJson(String source) =>
      NFTPrice.fromMap(json.decode(source) as Map<String, dynamic>);

  factory NFTPrice.fromMap(Map<String, dynamic> map) {
    return NFTPrice(
      openSea: NFTFloorPrice.fromMap(map['openSea'] as Map<String, dynamic>),
      looksRare:
          NFTFloorPrice.fromMap(map['looksRare'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'openSea': openSea.toMap(),
      'looksRare': looksRare.toMap(),
    };
  }
}

class NFTQueryResponse {
  final List<NFT>? _ownedNfts;
  final String? pageKey;
  final int? totalCount;
  final ResponseType responseType;

  NFTQueryResponse({
    List<NFT>? ownedNfts,
    this.pageKey,
    this.totalCount,
    required this.responseType,
  }) : _ownedNfts = ownedNfts;

  factory NFTQueryResponse.fromJson(String source, ResponseType responseType) =>
      NFTQueryResponse.fromMap(
          json.decode(source) as Map<String, dynamic>, responseType);

  factory NFTQueryResponse.fromMap(
      Map<String, dynamic> map, ResponseType responseType) {
    return NFTQueryResponse(
      ownedNfts: List<NFT>.from(
        (map['ownedNfts'] as List<int>).map<NFT?>(
          (x) => NFT.fromMap(x as Map<String, dynamic>, responseType),
        ),
      ),
      pageKey: map['pageKey'] != null ? map['pageKey'] as String : null,
      totalCount: map['totalCount'] != null ? map['totalCount'] as int : null,
      responseType: responseType,
    );
  }

  T nftList<T>() {
    if (responseType == ResponseType.withMetadata) {
      require(T is NFTMetadata, "generic doesn't match 'NftMetadata' type");
      return _ownedNfts as T;
    }
    require(T is NFT, "generic doesn't match 'NftMetadataMinified' type");
    return _ownedNfts as T;
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ownedNfts': _ownedNfts?.map((x) => x.toMap()).toList(),
      'ownedNftsMinified': _ownedNfts?.map((x) => x.toMap()).toList(),
      'pageKey': pageKey,
      'totalCount': totalCount,
      'responseType': responseType.name,
    };
  }
}
