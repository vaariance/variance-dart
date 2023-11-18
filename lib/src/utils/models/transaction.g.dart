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
      value: json['value'] as String,
      input: json['input'] as String?,
      nonce: json['nonce'] as num,
      contractAddress: json['contract_address'] as String?,
      gas: json['gas'] as num,
      gasPrice: json['gas_price'] as num,
      gasUsed: json['gas_used'] as num,
      effectiveGasPrice: json['effective_gas_price'] as num,
      cumulativeGasUsed: json['cumulative_gas_used'] as num,
      maxFeePerGas: json['max_fee_per_gas'] as num?,
      maxPriorityFeePerGas: json['max_priority_fee_per_gas'] as num?,
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
      'value': instance.value,
      'input': instance.input,
      'nonce': instance.nonce,
      'contract_address': instance.contractAddress,
      'gas': instance.gas,
      'gas_price': instance.gasPrice,
      'gas_used': instance.gasUsed,
      'effective_gas_price': instance.effectiveGasPrice,
      'cumulative_gas_used': instance.cumulativeGasUsed,
      'max_fee_per_gas': instance.maxFeePerGas,
      'max_priority_fee_per_gas': instance.maxPriorityFeePerGas,
      'tx_fee': instance.txFee,
      'saving_fee': instance.savingFee,
      'burnt_fee': instance.burntFee,
    };
