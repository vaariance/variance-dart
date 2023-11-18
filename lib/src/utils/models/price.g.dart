// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TokenPriceImpl _$$TokenPriceImplFromJson(Map<String, dynamic> json) =>
    _$TokenPriceImpl(
      price: json['price'] as num?,
      symbol: json['symbol'] as String?,
      decimals: json['decimals'] as num?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$TokenPriceImplToJson(_$TokenPriceImpl instance) =>
    <String, dynamic>{
      'price': instance.price,
      'symbol': instance.symbol,
      'decimals': instance.decimals,
      'updated_at': instance.updatedAt,
    };
