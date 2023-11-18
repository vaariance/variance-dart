// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NFTImpl _$$NFTImplFromJson(Map<String, dynamic> json) => _$NFTImpl(
      contractAddress: json['contract_address'] as String,
      ercType: json['erc_type'] as String?,
      floorPrices: (json['floor_prices'] as List<dynamic>?)
          ?.map((e) => NFTFloorPrice.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageUri: json['image_uri'] as String?,
      metadata: json['metadata'] == null
          ? null
          : NFTMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      mintTime: json['mint_time'] as String,
      mintTransactionHash: json['mint_transaction_hash'] as String,
      name: json['name'] as String?,
      owner: json['owner'] as String?,
      rarityRank: json['rarity_rank'] as num?,
      rarityScore: json['rarity_score'] as num?,
      symbol: json['symbol'] as String,
      tokenId: json['token_id'] as String,
      tokenUri: json['token_uri'] as String?,
      total: json['total'] as num?,
      totalString: json['total_string'] as String?,
      traits: (json['traits'] as List<dynamic>?)
          ?.map((e) => NFTAttributes.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$NFTImplToJson(_$NFTImpl instance) => <String, dynamic>{
      'contract_address': instance.contractAddress,
      'erc_type': instance.ercType,
      'floor_prices': instance.floorPrices,
      'image_uri': instance.imageUri,
      'metadata': instance.metadata,
      'mint_time': instance.mintTime,
      'mint_transaction_hash': instance.mintTransactionHash,
      'name': instance.name,
      'owner': instance.owner,
      'rarity_rank': instance.rarityRank,
      'rarity_score': instance.rarityScore,
      'symbol': instance.symbol,
      'token_id': instance.tokenId,
      'token_uri': instance.tokenUri,
      'total': instance.total,
      'total_string': instance.totalString,
      'traits': instance.traits,
    };
