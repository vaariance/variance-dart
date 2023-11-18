import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required num type,
    required num status,
    @JsonKey(name: 'block_number') required num blockNumber,
    @JsonKey(name: 'block_timestamp') required DateTime blockTimestamp,
    @JsonKey(name: 'transaction_hash') required String transactionHash,
    @JsonKey(name: 'transaction_index') required num transactionIndex,
    @JsonKey(name: 'from_address') required String fromAddress,
    @JsonKey(name: 'to_address') required String toAddress,
    required String value,
    required String? input,
    required num nonce,
    @JsonKey(name: 'contract_address') required String? contractAddress,
    required num gas,
    @JsonKey(name: 'gas_price') required num gasPrice,
    @JsonKey(name: 'gas_used') required num gasUsed,
    @JsonKey(name: 'effective_gas_price') required num effectiveGasPrice,
    @JsonKey(name: 'cumulative_gas_used') required num cumulativeGasUsed,
    @JsonKey(name: 'max_fee_per_gas') required num? maxFeePerGas,
    @JsonKey(name: 'max_priority_fee_per_gas')
    required num? maxPriorityFeePerGas,
    @JsonKey(name: 'tx_fee') required num txFee,
    @JsonKey(name: 'saving_fee') required num? savingFee,
    @JsonKey(name: 'burnt_fee') required num? burntFee,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}
