import 'dart:convert';

import 'package:pks_4337_sdk/src/common/uint256.dart';

class Collection {
  String name;
  String slug;
  String externalUrl;
  String? bannerImageUrl;

  Collection({
    required this.name,
    required this.slug,
    required this.externalUrl,
    required this.bannerImageUrl,
  });

  factory Collection.fromJson(String source) =>
      Collection.fromMap(json.decode(source) as Map<String, dynamic>);

  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      name: map['name'],
      slug: map['slug'],
      externalUrl: map['externalUrl'],
      bannerImageUrl: map['bannerImageUrl'],
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'slug': slug,
      'externalUrl': externalUrl,
      'bannerImageUrl': bannerImageUrl,
    };
  }
}

class ERC1155Metadata {
  final Uint256 tokenId;
  final Uint256 value;

  ERC1155Metadata(
    this.tokenId,
    this.value,
  );

  factory ERC1155Metadata.fromJson(String source) =>
      ERC1155Metadata.fromMap(json.decode(source) as Map<String, dynamic>);

  factory ERC1155Metadata.fromMap(Map<String, dynamic> map) {
    return ERC1155Metadata(
      Uint256.fromHex(map['tokenId']),
      Uint256.fromHex(map['value']),
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tokenId': tokenId.toHex(),
      'value': value.toHex(),
    };
  }
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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'image': image,
      'attributes': attributes,
    };
  }
}

class NFTUris {
  String? cachedUrl;
  String? thumbnailUrl;
  String? pngUrl;
  String? contentType;
  int? size;
  String? originalUrl;

  NFTUris({
    this.cachedUrl,
    this.thumbnailUrl,
    this.pngUrl,
    this.contentType,
    this.size,
    this.originalUrl,
  });

  factory NFTUris.fromJson(String source) =>
      NFTUris.fromMap(json.decode(source) as Map<String, dynamic>);

  factory NFTUris.fromMap(Map<String, dynamic> map) {
    return NFTUris(
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

  factory OpenSeaMetadata.fromJson(String source) =>
      OpenSeaMetadata.fromMap(json.decode(source) as Map<String, dynamic>);

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
      lastIngestedAt: DateTime.parse(map['lastIngestedAt']),
    );
  }

  String toJson() => json.encode(toMap());

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
}

class RawMetadata {
  final String? tokenUri;
  final Metadata? metadata;
  final String? error;

  RawMetadata({
    required this.tokenUri,
    this.metadata,
    this.error,
  });

  factory RawMetadata.fromJson(String source) =>
      RawMetadata.fromMap(json.decode(source) as Map<String, dynamic>);

  factory RawMetadata.fromMap(Map<String, dynamic> map) {
    return RawMetadata(
      tokenUri: map['tokenUri'],
      metadata: map['metadata'] != null
          ? Metadata.fromMap(map['metadata'] as Map<String, dynamic>)
          : null,
      error: map['error'] != null ? map['error'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tokenUri': tokenUri,
      'metadata': metadata?.toMap(),
      'error': error,
    };
  }
}
