// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TokenMetadataImpl _$$TokenMetadataImplFromJson(Map<String, dynamic> json) =>
    _$TokenMetadataImpl(
      contractAddress: json['contract_address'] as String,
      decimals: json['decimals'] as num,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      totalSupply: const BigIntConverter().fromJson(json['total_supply']),
      logos: (json['logos'] as List<dynamic>?)
          ?.map((e) => TokenLogo.fromJson(e as Map<String, dynamic>))
          .toList(),
      urls: (json['urls'] as List<dynamic>?)
          ?.map((e) => TokenUrl.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentUsdPrice: json['current_usd_price'] as num?,
    );

Map<String, dynamic> _$$TokenMetadataImplToJson(_$TokenMetadataImpl instance) =>
    <String, dynamic>{
      'contract_address': instance.contractAddress,
      'decimals': instance.decimals,
      'name': instance.name,
      'symbol': instance.symbol,
      'total_supply': const BigIntConverter().toJson(instance.totalSupply),
      'logos': instance.logos,
      'urls': instance.urls,
      'current_usd_price': instance.currentUsdPrice,
    };
