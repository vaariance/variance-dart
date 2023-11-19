import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:variance_dart/src/common/common.dart' show Uint256;
import 'package:variance_dart/utils.dart' show BigIntConverter;

part 'transfer.freezed.dart';
part 'transfer.g.dart';

@freezed
class TokenTransfer with _$TokenTransfer {
  const factory TokenTransfer({
    @JsonKey(name: 'block_number') required num blockNumber,
    @JsonKey(name: 'block_timestamp') required DateTime blockTimestamp,
    @JsonKey(name: 'contract_address') required String contractAddress,
    @JsonKey(name: 'from_address') required String fromAddress,
    @JsonKey(name: 'log_index') required num logIndex,
    @JsonKey(name: 'to_address') required String toAddress,
    @JsonKey(name: 'transaction_hash') required String transactionHash,
    @JsonKey(name: 'transaction_index') required num transactionIndex,
    @JsonKey(name: 'tx_fee') required num txFee,
    @JsonKey(name: 'tx_type') required num txType,
    @BigIntConverter() required Uint256 value,
  }) = _TokenTransfer;

  factory TokenTransfer.fromJson(Map<String, dynamic> json) =>
      _$TokenTransferFromJson(json);

  const TokenTransfer._();

  TxType direction(String compareAddress) {
    if (fromAddress.toLowerCase() == compareAddress.toLowerCase()) {
      return TxType.SEND;
    } else {
      return TxType.RECEIVE;
    }
  }
}

enum TxType { RECEIVE, SEND }
