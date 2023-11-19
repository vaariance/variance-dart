// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TokenImpl _$$TokenImplFromJson(Map<String, dynamic> json) => _$TokenImpl(
      balance: const HexConverter().fromJson(json['balance'] as String),
      contractAddress: json['contract_address'] as String,
      currentUsdPrice: json['current_usd_price'] as num?,
      decimals: json['decimals'] as num,
      logos: (json['logos'] as List<dynamic>?)
          ?.map((e) => TokenLogo.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      totalSupply: const BigIntConverter().fromJson(json['total_supply']),
      urls: (json['urls'] as List<dynamic>?)
          ?.map((e) => TokenUrl.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$TokenImplToJson(_$TokenImpl instance) =>
    <String, dynamic>{
      'balance': const HexConverter().toJson(instance.balance),
      'contract_address': instance.contractAddress,
      'current_usd_price': instance.currentUsdPrice,
      'decimals': instance.decimals,
      'logos': instance.logos,
      'name': instance.name,
      'symbol': instance.symbol,
      'total_supply': _$JsonConverterToJson<dynamic, Uint256>(
          instance.totalSupply, const BigIntConverter().toJson),
      'urls': instance.urls,
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
