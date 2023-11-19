// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TokenTransferImpl _$$TokenTransferImplFromJson(Map<String, dynamic> json) =>
    _$TokenTransferImpl(
      blockNumber: json['block_number'] as num,
      blockTimestamp: DateTime.parse(json['block_timestamp'] as String),
      contractAddress: json['contract_address'] as String,
      fromAddress: json['from_address'] as String,
      logIndex: json['log_index'] as num,
      toAddress: json['to_address'] as String,
      transactionHash: json['transaction_hash'] as String,
      transactionIndex: json['transaction_index'] as num,
      txFee: json['tx_fee'] as num,
      txType: json['tx_type'] as num,
      value: const BigIntConverter().fromJson(json['value']),
    );

Map<String, dynamic> _$$TokenTransferImplToJson(_$TokenTransferImpl instance) =>
    <String, dynamic>{
      'block_number': instance.blockNumber,
      'block_timestamp': instance.blockTimestamp.toIso8601String(),
      'contract_address': instance.contractAddress,
      'from_address': instance.fromAddress,
      'log_index': instance.logIndex,
      'to_address': instance.toAddress,
      'transaction_hash': instance.transactionHash,
      'transaction_index': instance.transactionIndex,
      'tx_fee': instance.txFee,
      'tx_type': instance.txType,
      'value': const BigIntConverter().toJson(instance.value),
    };
