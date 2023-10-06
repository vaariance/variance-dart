import 'dart:convert';
import 'dart:typed_data';
import 'dart:developer';

import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/4337/modules/contract.dart';
import 'package:pks_4337_sdk/src/4337/modules/alchemyApi/utils/enum.dart';
import 'package:pks_4337_sdk/src/4337/modules/alchemyApi/utils/metadatas.dart';
import 'package:pks_4337_sdk/src/4337/wallet.dart' as sdk;
import 'package:pks_4337_sdk/src/abi/abis.dart';
import 'package:pks_4337_sdk/src/dio_client.dart';
import 'package:web3dart/web3dart.dart';

///[ERC721] module
///
/// uses alchemy nft api
/// if want to use another api, you have to create a custom class
class ERC721 {
  final Uri _baseNftApiUrl;

  final _dioClient = DioClient();

  ERC721(String rpcUrl)
      : _baseNftApiUrl = Uri.parse(ERC721.getBaseNftApiUrl(rpcUrl));

  /// [getFloorPrice] returns the lowest listing price of an NFT
  /// - @param [contractAddress] is the address of the contract
  /// returns the [NFTPrice]
  Future<NFTPrice> getFloorPrice(EthereumAddress contractAddress) async {
    final response = await _fetchNftRequest(
      "${_baseNftApiUrl.path}/getFloorPrice",
      {'contractAddress': contractAddress.hex},
    );
    return NFTPrice.fromMap(response);
  }

  /// [getNftMetadata] returns the metadata of a fetched NFT
  /// - @param [contractAddress] is the address of the contract
  /// - @param [tokenId] is the tokenId of the NFT
  /// - @param optional [type] is the type of the NFT
  /// - @param optional [refreshCache] is to refresh the cache
  /// returns the [NFTMetadata]
  Future<NFTMetadata> getNftMetadata(
      EthereumAddress contractAddress, Uint256 tokenId,
      {NftTokenType? type, bool refreshCache = false}) async {
    final queryParams = {
      'contractAddress': contractAddress.hex,
      'tokenId': tokenId.toString(),
      'refreshCache': refreshCache.toString(),
    };
    // Add token type to the query parameters if not null
    if (type != null) {
      queryParams['tokenType'] = type.name.toUpperCase();
    }

    final response = await _fetchNftRequest(
      "${_baseNftApiUrl.path}/getNFTMetadata",
      queryParams,
    );
    return NFTMetadata.fromMap(response);
  }

  /// [getNftsForOwner] returns the NFTs owned by an address
  /// - @param [address] is the owner address
  /// - @param optional [pageKey] is the page key for pagination
  /// - @param optional [orderByTransferTime] is true if you want to sort by transfer time
  /// - @param optional [withMetadata] is true if you want to get metadata
  /// returns an [NFTQueryResponse] object
  Future<NFTQueryResponse> getNftsForOwner(EthereumAddress address,
      {bool orderByTransferTime = false,
      bool withMetadata = true,
      String? pageKey}) async {
    final queryParams = {
      'owner': address.hex,
      'withMetadata': withMetadata.toString(),
      if (orderByTransferTime) 'orderBy': 'transferTime',
    };

    if (pageKey != null) {
      queryParams['pageKey'] = pageKey;
    }

    final response = await _fetchNftRequest(
      "${_baseNftApiUrl.path}/getNFTsForOwner",
      queryParams,
    );

    return NFTQueryResponse.fromMap(
        response,
        withMetadata
            ? ResponseType.withMetadata
            : ResponseType.withoutMetadata);
  }

  /// [isAirdropNFT] checks if an NFT of a contract is an airdrop or not
  /// - @param [contractAddress] is the contract address of the NFT
  /// - @param [tokenId] is the tokenId of the NFT
  /// returns true or false if the NFT is marked as airdrop or not
  Future<bool> isAirdropNFT(
      EthereumAddress contractAddress, Uint256 tokenId) async {
    final response = await _fetchNftRequest(
      "${_baseNftApiUrl.path}/isAirdropNFT",
      {'contractAddress': contractAddress.hex, 'tokenId': tokenId.toString()},
    );

    //returns true or false depending on if the NFT is an airdrop
    return response["isAirdrop"] as bool;
  }

  /// [isSpamContract] checks if an NFT is a spam
  Future<bool> isSpamContract(EthereumAddress contractAddress) async {
    final response = await _fetchNftRequest(
      "${_baseNftApiUrl.path}/isSpamContract",
      {'contractAddress': contractAddress.hex},
    );
    return response["isSpamContract"] as bool;
  }

  ///fetches NFT data
  ///
  ///`path` is the endpoint or path of the API
  ///
  ///`queryParams` The query parameters to be sent with the request
  Future<Map<String, dynamic>> _fetchNftRequest(
    String path,
    Map<String, Object?> queryParams,
  ) async {
    final String requestUrl = _baseNftApiUrl
        .replace(path: path)
        .replace(queryParameters: queryParams)
        .toString();

    log("requestUrl: $requestUrl");
    return await _dioClient.callNftApi<Map<String, dynamic>>(
      requestUrl,
    );
  }

  /// [encodeERC721ApproveCall] returns the callData for ERC721
  /// {@template approve}
  /// - @param [contractAddress] is the address of the contract
  /// - @param [to] is the address to approve
  /// - @param [tokenId] is the tokenId to approve
  /// {@endtemplate}
  static Uint8List encodeERC721ApproveCall(
      EthereumAddress contractAddress, EthereumAddress to, BigInt tokenId) {
    return Contract.encodeFunctionCall("approve", contractAddress,
        ContractAbis.get("ERC721"), [to.hex, tokenId]);
  }

  /// [encodeERC721SafeTransferCall] encodes the callData for ERC721
  /// {@macro approve}
  /// - @param [from] is the address to transfer from
  static Uint8List encodeERC721SafeTransferCall(EthereumAddress contractAddress,
      EthereumAddress from, EthereumAddress to, BigInt tokenId) {
    return Contract.encodeFunctionCall("safeTransferFrom", contractAddress,
        ContractAbis.get("ERC721"), [from.hex, to.hex, tokenId]);
  }

  /// gets NFT api url
  static String getBaseNftApiUrl(String rpcUrl) {
    final sections = rpcUrl.split('/v2/');
    sections[1] = "/nft/v3/${sections[1]}";
    return sections.join('');
  }
}

class NFT {
  final EthereumAddress address;
  final BigInt tokenId;
  final BigInt balance;
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
      address: EthereumAddress.fromHex(responseType == ResponseType.withMetadata
          ? map['contract']['address']
          : map['contractAddress']),
      tokenId: BigInt.parse(map['tokenId']),
      balance: BigInt.parse(map['balance']),
      metadata: responseType == ResponseType.withMetadata
          ? NFTMetadata.fromMap(map)
          : null,
    );
  }

  /// [approveNFT] returns a [UserOperation] to approve the spender of the NFT
  /// - @param [owner] is the address of the owner of the NFT
  /// - @param [spender] is the address of the spender of the NFT
  Future<UserOperation> approveNFT(
      EthereumAddress owner, EthereumAddress spender) async {
    final innerCallData = sdk.Wallet.callData(owner,
        to: address,
        innerCallData: ERC721.encodeERC721ApproveCall(
          address,
          spender,
          tokenId,
        ));
    return UserOperation.partial(hexlify(innerCallData));
  }

  /// [transferNFT] returns a [UserOperation] to transfer an NFT
  /// - @param [owner] is the address of the owner of the NFT
  /// - @param [spender] is the address of the spender of the NFT
  Future<UserOperation> transferNFT(
      EthereumAddress owner, EthereumAddress spender) async {
    final innerCallData = sdk.Wallet.callData(owner,
        to: address,
        innerCallData: ERC721.encodeERC721SafeTransferCall(
          address,
          owner,
          spender,
          tokenId,
        ));
    return UserOperation.partial(hexlify(innerCallData));
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
}

/// [NFTFloorPrice] response model for a NFT floor price
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

/// [NFTMetadata] is the metadata model for an NFT
class NFTMetadata {
  String address;
  String? name;
  String? symbol;
  int? totalSupply;
  String tokenType;
  bool? isSpam;
  BigInt tokenId;
  String? tokenUri;
  OpenSeaMetadata? openSeaMetadata;
  Collection? collection;
  NFTUris image;
  RawMetadata raw;
  BigInt? balance;
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
    //log("message: $map");
    return NFTMetadata(
      address: map['contract']['address'],
      name: map['contract']['name'],
      symbol: map['contract']['symbol'],
      totalSupply:
          map['totalSupply'] != null ? map['totalSupply'] as int : null,
      tokenType: map['tokenType'],
      isSpam: map['isSpam'],
      tokenId: BigInt.parse(map['tokenId']),
      tokenUri: map['tokenUri'],
      openSeaMetadata: map['openSeaMetadata'] != null
          ? OpenSeaMetadata.fromMap(
              map['openSeaMetadata'] as Map<String, dynamic>)
          : null,
      collection: map['collection'] != null
          ? Collection.fromMap(map['collection'] as Map<String, dynamic>)
          : null,
      image: NFTUris.fromMap(map['image'] as Map<String, dynamic>),
      raw: RawMetadata.fromMap(map['raw'] as Map<String, dynamic>),
      balance: map['balance'] != null ? BigInt.parse(map['balance']) : null,
      timeStamp: map['acquiredAt'] != null
          ? map['acquiredAt']['timeStamp'] != null
              ? DateTime.parse(map['acquiredAt']['timeStamp'])
              : null
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

/// [NFTPrice] response model for a NFT price
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

/// [NFTQueryResponse] response model for a NFT query
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
        (map['ownedNfts'] as List<dynamic>).map<NFT?>(
          (x) => NFT.fromMap(x as Map<String, dynamic>, responseType),
        ),
      ),
      pageKey: map['pageKey'],
      totalCount: map['totalCount'],
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
