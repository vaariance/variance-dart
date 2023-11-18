// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TokenImpl _$$TokenImplFromJson(Map<String, dynamic> json) => _$TokenImpl(
      balance: json['balance'] as String,
      contractAddress: json['contract_address'] as String,
      currentUsdPrice: json['current_usd_price'] as num?,
      decimals: json['decimals'] as num,
      logos: (json['logos'] as List<dynamic>?)
          ?.map((e) => TokenLogo.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      totalSupply: json['total_supply'] as String?,
      urls: (json['urls'] as List<dynamic>?)
          ?.map((e) => TokenUrl.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$TokenImplToJson(_$TokenImpl instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'contract_address': instance.contractAddress,
      'current_usd_price': instance.currentUsdPrice,
      'decimals': instance.decimals,
      'logos': instance.logos,
      'name': instance.name,
      'symbol': instance.symbol,
      'total_supply': instance.totalSupply,
      'urls': instance.urls,
    };
