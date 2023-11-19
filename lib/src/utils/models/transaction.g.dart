// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionImpl _$$TransactionImplFromJson(Map<String, dynamic> json) =>
    _$TransactionImpl(
      type: json['type'] as num,
      status: json['status'] as num,
      blockNumber: json['block_number'] as num,
      blockTimestamp: DateTime.parse(json['block_timestamp'] as String),
      transactionHash: json['transaction_hash'] as String,
      transactionIndex: json['transaction_index'] as num,
      fromAddress: json['from_address'] as String,
      toAddress: json['to_address'] as String,
      value: const BigIntConverter().fromJson(json['value']),
      input: json['input'] as String?,
      nonce: json['nonce'] as num,
      contractAddress: json['contract_address'] as String?,
      gas: const BigIntConverter().fromJson(json['gas']),
      gasPrice: const BigIntConverter().fromJson(json['gas_price']),
      gasUsed: const BigIntConverter().fromJson(json['gas_used']),
      effectiveGasPrice:
          const BigIntConverter().fromJson(json['effective_gas_price']),
      cumulativeGasUsed:
          const BigIntConverter().fromJson(json['cumulative_gas_used']),
      maxFeePerGas: const BigIntConverter().fromJson(json['max_fee_per_gas']),
      maxPriorityFeePerGas:
          const BigIntConverter().fromJson(json['max_priority_fee_per_gas']),
      txFee: json['tx_fee'] as num,
      savingFee: json['saving_fee'] as num?,
      burntFee: json['burnt_fee'] as num?,
    );

Map<String, dynamic> _$$TransactionImplToJson(_$TransactionImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'status': instance.status,
      'block_number': instance.blockNumber,
      'block_timestamp': instance.blockTimestamp.toIso8601String(),
      'transaction_hash': instance.transactionHash,
      'transaction_index': instance.transactionIndex,
      'from_address': instance.fromAddress,
      'to_address': instance.toAddress,
      'value': const BigIntConverter().toJson(instance.value),
      'input': instance.input,
      'nonce': instance.nonce,
      'contract_address': instance.contractAddress,
      'gas': const BigIntConverter().toJson(instance.gas),
      'gas_price': const BigIntConverter().toJson(instance.gasPrice),
      'gas_used': const BigIntConverter().toJson(instance.gasUsed),
      'effective_gas_price':
          const BigIntConverter().toJson(instance.effectiveGasPrice),
      'cumulative_gas_used':
          const BigIntConverter().toJson(instance.cumulativeGasUsed),
      'max_fee_per_gas': _$JsonConverterToJson<dynamic, Uint256>(
          instance.maxFeePerGas, const BigIntConverter().toJson),
      'max_priority_fee_per_gas': _$JsonConverterToJson<dynamic, Uint256>(
          instance.maxPriorityFeePerGas, const BigIntConverter().toJson),
      'tx_fee': instance.txFee,
      'saving_fee': instance.savingFee,
      'burnt_fee': instance.burntFee,
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
