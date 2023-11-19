import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:variance_dart/src/common/common.dart' show Uint256;
import 'package:variance_dart/utils.dart' show BigIntConverter;

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
    @BigIntConverter() required Uint256 value,
    required String? input,
    required num nonce,
    @JsonKey(name: 'contract_address') required String? contractAddress,
    @BigIntConverter() required Uint256 gas,
    @BigIntConverter() @JsonKey(name: 'gas_price') required Uint256 gasPrice,
    @BigIntConverter() @JsonKey(name: 'gas_used') required Uint256 gasUsed,
    @BigIntConverter()
    @JsonKey(name: 'effective_gas_price')
    required Uint256 effectiveGasPrice,
    @BigIntConverter()
    @JsonKey(name: 'cumulative_gas_used')
    required Uint256 cumulativeGasUsed,
    @BigIntConverter()
    @JsonKey(name: 'max_fee_per_gas')
    required Uint256? maxFeePerGas,
    @BigIntConverter()
    @JsonKey(name: 'max_priority_fee_per_gas')
    required Uint256? maxPriorityFeePerGas,
    @JsonKey(name: 'tx_fee') required num txFee,
    @JsonKey(name: 'saving_fee') required num? savingFee,
    @JsonKey(name: 'burnt_fee') required num? burntFee,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}
