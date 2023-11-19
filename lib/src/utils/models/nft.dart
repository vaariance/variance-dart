import 'package:freezed_annotation/freezed_annotation.dart';

part 'nft.freezed.dart';
part 'nft.g.dart';

@freezed
class NFT with _$NFT {
  const factory NFT({
    @JsonKey(name: 'contract_address') required String contractAddress,
    @JsonKey(name: 'erc_type') required String? ercType,
    @JsonKey(name: 'floor_prices') required List<NFTFloorPrice>? floorPrices,
    @JsonKey(name: 'image_uri') required String? imageUri,
    required NFTMetadata? metadata,
    @JsonKey(name: 'mint_time') required DateTime mintTime,
    @JsonKey(name: 'mint_transaction_hash') required String mintTransactionHash,
    required String? name,
    required String? owner,
    @JsonKey(name: 'rarity_rank') required num? rarityRank,
    @JsonKey(name: 'rarity_score') required num? rarityScore,
    required String symbol,
    @JsonKey(name: 'token_id') required String tokenId,
    @JsonKey(name: 'token_uri') required String? tokenUri,
    required num? total,
    @JsonKey(name: 'total_string') required String? totalString,
    required List<NFTAttributes>? traits,
  }) = _NFT;

  factory NFT.fromJson(Map<String, dynamic> json) => _$NFTFromJson(json);
}

class NFTMetadata {
  NFTMetadata({
    required this.attributes,
    required this.backgroundImage,
    required this.description,
    required this.image,
    required this.imageUrl,
    required this.isNormalized,
    required this.name,
    required this.nameLength,
    required this.segmentLength,
    required this.url,
    required this.version,
  });

  factory NFTMetadata.fromJson(Map<String, dynamic> json) => NFTMetadata(
        attributes: json['attributes'] != null
            ? List<NFTAttributes>.from(
                json['attributes'].map((x) => NFTAttributes.fromJson(x)))
            : null,
        backgroundImage: json['background_image'],
        description: json['description'],
        image: json['image'],
        imageUrl: json['image_url'],
        isNormalized: json['is_normalized'],
        name: json['name'],
        nameLength: json['name_length'],
        segmentLength: json['segment_length'],
        url: json['url'],
        version: json['version'],
      );

  final List<NFTAttributes>? attributes;
  final String? backgroundImage;
  final String? description;
  final String? image;
  final String? imageUrl;
  final bool? isNormalized;
  final String? name;
  final num? nameLength;
  final num? segmentLength;
  final String? url;
  final num? version;

  Map<String, dynamic> toJson() => {
        'attributes': attributes != null
            ? attributes!.map((x) => x.toJson()).toList()
            : null,
        'background_image': backgroundImage,
        'description': description,
        'image': image,
        'image_url': imageUrl,
        'is_normalized': isNormalized,
        'name': name,
        'name_length': nameLength,
        'segment_length': segmentLength,
        'url': url,
        'version': version,
      };
}

class NFTAttributes {
  NFTAttributes({
    required this.displayType,
    required this.traitType,
    required this.value,
  });

  factory NFTAttributes.fromJson(Map<String, dynamic> json) => NFTAttributes(
        displayType: json['display_type'],
        traitType: json['trait_type'],
        value: json['value'],
      );

  final String? displayType;
  final String? traitType;
  final dynamic value;

  Map<String, dynamic> toJson() => {
        'display_type': displayType,
        'trait_type': traitType,
        'value': value,
      };
}

class NFTFloorPrice {
  NFTFloorPrice({
    required this.address,
    required this.symbol,
    required this.value,
  });

  factory NFTFloorPrice.fromJson(Map<String, dynamic> json) => NFTFloorPrice(
        address: json['address'],
        symbol: json['symbol'],
        value: json['value'],
      );

  final String address;
  final String symbol;
  final String value;

  Map<String, dynamic> toJson() => {
        'address': address,
        'symbol': symbol,
        'value': value,
      };
}
