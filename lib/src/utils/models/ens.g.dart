// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ens.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ENSImpl _$$ENSImplFromJson(Map<String, dynamic> json) => _$ENSImpl(
      name: json['name'] as String,
      address: json['address'] as String,
      registrant: json['registrant'] as String,
      owner: json['owner'] as String,
      resolver: json['resolver'] as String,
      registrantTime: DateTime.parse(json['registrant_time'] as String),
      expirationTime: DateTime.parse(json['expiration_time'] as String),
      tokenId: json['token_id'] as String,
      textRecords: json['text_records'],
    );

Map<String, dynamic> _$$ENSImplToJson(_$ENSImpl instance) => <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'registrant': instance.registrant,
      'owner': instance.owner,
      'resolver': instance.resolver,
      'registrant_time': instance.registrantTime.toIso8601String(),
      'expiration_time': instance.expirationTime.toIso8601String(),
      'token_id': instance.tokenId,
      'text_records': instance.textRecords,
    };
