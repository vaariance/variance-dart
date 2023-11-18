// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return _Transaction.fromJson(json);
}

/// @nodoc
mixin _$Transaction {
  num get type => throw _privateConstructorUsedError;
  num get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'block_number')
  num get blockNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'block_timestamp')
  DateTime get blockTimestamp => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_hash')
  String get transactionHash => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_index')
  num get transactionIndex => throw _privateConstructorUsedError;
  @JsonKey(name: 'from_address')
  String get fromAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'to_address')
  String get toAddress => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  String? get input => throw _privateConstructorUsedError;
  num get nonce => throw _privateConstructorUsedError;
  @JsonKey(name: 'contract_address')
  String? get contractAddress => throw _privateConstructorUsedError;
  num get gas => throw _privateConstructorUsedError;
  @JsonKey(name: 'gas_price')
  num get gasPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'gas_used')
  num get gasUsed => throw _privateConstructorUsedError;
  @JsonKey(name: 'effective_gas_price')
  num get effectiveGasPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'cumulative_gas_used')
  num get cumulativeGasUsed => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_fee_per_gas')
  num? get maxFeePerGas => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_priority_fee_per_gas')
  num? get maxPriorityFeePerGas => throw _privateConstructorUsedError;
  @JsonKey(name: 'tx_fee')
  num get txFee => throw _privateConstructorUsedError;
  @JsonKey(name: 'saving_fee')
  num? get savingFee => throw _privateConstructorUsedError;
  @JsonKey(name: 'burnt_fee')
  num? get burntFee => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TransactionCopyWith<Transaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCopyWith<$Res> {
  factory $TransactionCopyWith(
          Transaction value, $Res Function(Transaction) then) =
      _$TransactionCopyWithImpl<$Res, Transaction>;
  @useResult
  $Res call(
      {num type,
      num status,
      @JsonKey(name: 'block_number') num blockNumber,
      @JsonKey(name: 'block_timestamp') DateTime blockTimestamp,
      @JsonKey(name: 'transaction_hash') String transactionHash,
      @JsonKey(name: 'transaction_index') num transactionIndex,
      @JsonKey(name: 'from_address') String fromAddress,
      @JsonKey(name: 'to_address') String toAddress,
      String value,
      String? input,
      num nonce,
      @JsonKey(name: 'contract_address') String? contractAddress,
      num gas,
      @JsonKey(name: 'gas_price') num gasPrice,
      @JsonKey(name: 'gas_used') num gasUsed,
      @JsonKey(name: 'effective_gas_price') num effectiveGasPrice,
      @JsonKey(name: 'cumulative_gas_used') num cumulativeGasUsed,
      @JsonKey(name: 'max_fee_per_gas') num? maxFeePerGas,
      @JsonKey(name: 'max_priority_fee_per_gas') num? maxPriorityFeePerGas,
      @JsonKey(name: 'tx_fee') num txFee,
      @JsonKey(name: 'saving_fee') num? savingFee,
      @JsonKey(name: 'burnt_fee') num? burntFee});
}

/// @nodoc
class _$TransactionCopyWithImpl<$Res, $Val extends Transaction>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? status = null,
    Object? blockNumber = null,
    Object? blockTimestamp = null,
    Object? transactionHash = null,
    Object? transactionIndex = null,
    Object? fromAddress = null,
    Object? toAddress = null,
    Object? value = null,
    Object? input = freezed,
    Object? nonce = null,
    Object? contractAddress = freezed,
    Object? gas = null,
    Object? gasPrice = null,
    Object? gasUsed = null,
    Object? effectiveGasPrice = null,
    Object? cumulativeGasUsed = null,
    Object? maxFeePerGas = freezed,
    Object? maxPriorityFeePerGas = freezed,
    Object? txFee = null,
    Object? savingFee = freezed,
    Object? burntFee = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as num,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as num,
      blockNumber: null == blockNumber
          ? _value.blockNumber
          : blockNumber // ignore: cast_nullable_to_non_nullable
              as num,
      blockTimestamp: null == blockTimestamp
          ? _value.blockTimestamp
          : blockTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      transactionHash: null == transactionHash
          ? _value.transactionHash
          : transactionHash // ignore: cast_nullable_to_non_nullable
              as String,
      transactionIndex: null == transactionIndex
          ? _value.transactionIndex
          : transactionIndex // ignore: cast_nullable_to_non_nullable
              as num,
      fromAddress: null == fromAddress
          ? _value.fromAddress
          : fromAddress // ignore: cast_nullable_to_non_nullable
              as String,
      toAddress: null == toAddress
          ? _value.toAddress
          : toAddress // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      input: freezed == input
          ? _value.input
          : input // ignore: cast_nullable_to_non_nullable
              as String?,
      nonce: null == nonce
          ? _value.nonce
          : nonce // ignore: cast_nullable_to_non_nullable
              as num,
      contractAddress: freezed == contractAddress
          ? _value.contractAddress
          : contractAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      gas: null == gas
          ? _value.gas
          : gas // ignore: cast_nullable_to_non_nullable
              as num,
      gasPrice: null == gasPrice
          ? _value.gasPrice
          : gasPrice // ignore: cast_nullable_to_non_nullable
              as num,
      gasUsed: null == gasUsed
          ? _value.gasUsed
          : gasUsed // ignore: cast_nullable_to_non_nullable
              as num,
      effectiveGasPrice: null == effectiveGasPrice
          ? _value.effectiveGasPrice
          : effectiveGasPrice // ignore: cast_nullable_to_non_nullable
              as num,
      cumulativeGasUsed: null == cumulativeGasUsed
          ? _value.cumulativeGasUsed
          : cumulativeGasUsed // ignore: cast_nullable_to_non_nullable
              as num,
      maxFeePerGas: freezed == maxFeePerGas
          ? _value.maxFeePerGas
          : maxFeePerGas // ignore: cast_nullable_to_non_nullable
              as num?,
      maxPriorityFeePerGas: freezed == maxPriorityFeePerGas
          ? _value.maxPriorityFeePerGas
          : maxPriorityFeePerGas // ignore: cast_nullable_to_non_nullable
              as num?,
      txFee: null == txFee
          ? _value.txFee
          : txFee // ignore: cast_nullable_to_non_nullable
              as num,
      savingFee: freezed == savingFee
          ? _value.savingFee
          : savingFee // ignore: cast_nullable_to_non_nullable
              as num?,
      burntFee: freezed == burntFee
          ? _value.burntFee
          : burntFee // ignore: cast_nullable_to_non_nullable
              as num?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransactionImplCopyWith<$Res>
    implements $TransactionCopyWith<$Res> {
  factory _$$TransactionImplCopyWith(
          _$TransactionImpl value, $Res Function(_$TransactionImpl) then) =
      __$$TransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {num type,
      num status,
      @JsonKey(name: 'block_number') num blockNumber,
      @JsonKey(name: 'block_timestamp') DateTime blockTimestamp,
      @JsonKey(name: 'transaction_hash') String transactionHash,
      @JsonKey(name: 'transaction_index') num transactionIndex,
      @JsonKey(name: 'from_address') String fromAddress,
      @JsonKey(name: 'to_address') String toAddress,
      String value,
      String? input,
      num nonce,
      @JsonKey(name: 'contract_address') String? contractAddress,
      num gas,
      @JsonKey(name: 'gas_price') num gasPrice,
      @JsonKey(name: 'gas_used') num gasUsed,
      @JsonKey(name: 'effective_gas_price') num effectiveGasPrice,
      @JsonKey(name: 'cumulative_gas_used') num cumulativeGasUsed,
      @JsonKey(name: 'max_fee_per_gas') num? maxFeePerGas,
      @JsonKey(name: 'max_priority_fee_per_gas') num? maxPriorityFeePerGas,
      @JsonKey(name: 'tx_fee') num txFee,
      @JsonKey(name: 'saving_fee') num? savingFee,
      @JsonKey(name: 'burnt_fee') num? burntFee});
}

/// @nodoc
class __$$TransactionImplCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$TransactionImpl>
    implements _$$TransactionImplCopyWith<$Res> {
  __$$TransactionImplCopyWithImpl(
      _$TransactionImpl _value, $Res Function(_$TransactionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? status = null,
    Object? blockNumber = null,
    Object? blockTimestamp = null,
    Object? transactionHash = null,
    Object? transactionIndex = null,
    Object? fromAddress = null,
    Object? toAddress = null,
    Object? value = null,
    Object? input = freezed,
    Object? nonce = null,
    Object? contractAddress = freezed,
    Object? gas = null,
    Object? gasPrice = null,
    Object? gasUsed = null,
    Object? effectiveGasPrice = null,
    Object? cumulativeGasUsed = null,
    Object? maxFeePerGas = freezed,
    Object? maxPriorityFeePerGas = freezed,
    Object? txFee = null,
    Object? savingFee = freezed,
    Object? burntFee = freezed,
  }) {
    return _then(_$TransactionImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as num,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as num,
      blockNumber: null == blockNumber
          ? _value.blockNumber
          : blockNumber // ignore: cast_nullable_to_non_nullable
              as num,
      blockTimestamp: null == blockTimestamp
          ? _value.blockTimestamp
          : blockTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      transactionHash: null == transactionHash
          ? _value.transactionHash
          : transactionHash // ignore: cast_nullable_to_non_nullable
              as String,
      transactionIndex: null == transactionIndex
          ? _value.transactionIndex
          : transactionIndex // ignore: cast_nullable_to_non_nullable
              as num,
      fromAddress: null == fromAddress
          ? _value.fromAddress
          : fromAddress // ignore: cast_nullable_to_non_nullable
              as String,
      toAddress: null == toAddress
          ? _value.toAddress
          : toAddress // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      input: freezed == input
          ? _value.input
          : input // ignore: cast_nullable_to_non_nullable
              as String?,
      nonce: null == nonce
          ? _value.nonce
          : nonce // ignore: cast_nullable_to_non_nullable
              as num,
      contractAddress: freezed == contractAddress
          ? _value.contractAddress
          : contractAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      gas: null == gas
          ? _value.gas
          : gas // ignore: cast_nullable_to_non_nullable
              as num,
      gasPrice: null == gasPrice
          ? _value.gasPrice
          : gasPrice // ignore: cast_nullable_to_non_nullable
              as num,
      gasUsed: null == gasUsed
          ? _value.gasUsed
          : gasUsed // ignore: cast_nullable_to_non_nullable
              as num,
      effectiveGasPrice: null == effectiveGasPrice
          ? _value.effectiveGasPrice
          : effectiveGasPrice // ignore: cast_nullable_to_non_nullable
              as num,
      cumulativeGasUsed: null == cumulativeGasUsed
          ? _value.cumulativeGasUsed
          : cumulativeGasUsed // ignore: cast_nullable_to_non_nullable
              as num,
      maxFeePerGas: freezed == maxFeePerGas
          ? _value.maxFeePerGas
          : maxFeePerGas // ignore: cast_nullable_to_non_nullable
              as num?,
      maxPriorityFeePerGas: freezed == maxPriorityFeePerGas
          ? _value.maxPriorityFeePerGas
          : maxPriorityFeePerGas // ignore: cast_nullable_to_non_nullable
              as num?,
      txFee: null == txFee
          ? _value.txFee
          : txFee // ignore: cast_nullable_to_non_nullable
              as num,
      savingFee: freezed == savingFee
          ? _value.savingFee
          : savingFee // ignore: cast_nullable_to_non_nullable
              as num?,
      burntFee: freezed == burntFee
          ? _value.burntFee
          : burntFee // ignore: cast_nullable_to_non_nullable
              as num?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionImpl implements _Transaction {
  const _$TransactionImpl(
      {required this.type,
      required this.status,
      @JsonKey(name: 'block_number') required this.blockNumber,
      @JsonKey(name: 'block_timestamp') required this.blockTimestamp,
      @JsonKey(name: 'transaction_hash') required this.transactionHash,
      @JsonKey(name: 'transaction_index') required this.transactionIndex,
      @JsonKey(name: 'from_address') required this.fromAddress,
      @JsonKey(name: 'to_address') required this.toAddress,
      required this.value,
      required this.input,
      required this.nonce,
      @JsonKey(name: 'contract_address') required this.contractAddress,
      required this.gas,
      @JsonKey(name: 'gas_price') required this.gasPrice,
      @JsonKey(name: 'gas_used') required this.gasUsed,
      @JsonKey(name: 'effective_gas_price') required this.effectiveGasPrice,
      @JsonKey(name: 'cumulative_gas_used') required this.cumulativeGasUsed,
      @JsonKey(name: 'max_fee_per_gas') required this.maxFeePerGas,
      @JsonKey(name: 'max_priority_fee_per_gas')
      required this.maxPriorityFeePerGas,
      @JsonKey(name: 'tx_fee') required this.txFee,
      @JsonKey(name: 'saving_fee') required this.savingFee,
      @JsonKey(name: 'burnt_fee') required this.burntFee});

  factory _$TransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionImplFromJson(json);

  @override
  final num type;
  @override
  final num status;
  @override
  @JsonKey(name: 'block_number')
  final num blockNumber;
  @override
  @JsonKey(name: 'block_timestamp')
  final DateTime blockTimestamp;
  @override
  @JsonKey(name: 'transaction_hash')
  final String transactionHash;
  @override
  @JsonKey(name: 'transaction_index')
  final num transactionIndex;
  @override
  @JsonKey(name: 'from_address')
  final String fromAddress;
  @override
  @JsonKey(name: 'to_address')
  final String toAddress;
  @override
  final String value;
  @override
  final String? input;
  @override
  final num nonce;
  @override
  @JsonKey(name: 'contract_address')
  final String? contractAddress;
  @override
  final num gas;
  @override
  @JsonKey(name: 'gas_price')
  final num gasPrice;
  @override
  @JsonKey(name: 'gas_used')
  final num gasUsed;
  @override
  @JsonKey(name: 'effective_gas_price')
  final num effectiveGasPrice;
  @override
  @JsonKey(name: 'cumulative_gas_used')
  final num cumulativeGasUsed;
  @override
  @JsonKey(name: 'max_fee_per_gas')
  final num? maxFeePerGas;
  @override
  @JsonKey(name: 'max_priority_fee_per_gas')
  final num? maxPriorityFeePerGas;
  @override
  @JsonKey(name: 'tx_fee')
  final num txFee;
  @override
  @JsonKey(name: 'saving_fee')
  final num? savingFee;
  @override
  @JsonKey(name: 'burnt_fee')
  final num? burntFee;

  @override
  String toString() {
    return 'Transaction(type: $type, status: $status, blockNumber: $blockNumber, blockTimestamp: $blockTimestamp, transactionHash: $transactionHash, transactionIndex: $transactionIndex, fromAddress: $fromAddress, toAddress: $toAddress, value: $value, input: $input, nonce: $nonce, contractAddress: $contractAddress, gas: $gas, gasPrice: $gasPrice, gasUsed: $gasUsed, effectiveGasPrice: $effectiveGasPrice, cumulativeGasUsed: $cumulativeGasUsed, maxFeePerGas: $maxFeePerGas, maxPriorityFeePerGas: $maxPriorityFeePerGas, txFee: $txFee, savingFee: $savingFee, burntFee: $burntFee)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.blockNumber, blockNumber) ||
                other.blockNumber == blockNumber) &&
            (identical(other.blockTimestamp, blockTimestamp) ||
                other.blockTimestamp == blockTimestamp) &&
            (identical(other.transactionHash, transactionHash) ||
                other.transactionHash == transactionHash) &&
            (identical(other.transactionIndex, transactionIndex) ||
                other.transactionIndex == transactionIndex) &&
            (identical(other.fromAddress, fromAddress) ||
                other.fromAddress == fromAddress) &&
            (identical(other.toAddress, toAddress) ||
                other.toAddress == toAddress) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.input, input) || other.input == input) &&
            (identical(other.nonce, nonce) || other.nonce == nonce) &&
            (identical(other.contractAddress, contractAddress) ||
                other.contractAddress == contractAddress) &&
            (identical(other.gas, gas) || other.gas == gas) &&
            (identical(other.gasPrice, gasPrice) ||
                other.gasPrice == gasPrice) &&
            (identical(other.gasUsed, gasUsed) || other.gasUsed == gasUsed) &&
            (identical(other.effectiveGasPrice, effectiveGasPrice) ||
                other.effectiveGasPrice == effectiveGasPrice) &&
            (identical(other.cumulativeGasUsed, cumulativeGasUsed) ||
                other.cumulativeGasUsed == cumulativeGasUsed) &&
            (identical(other.maxFeePerGas, maxFeePerGas) ||
                other.maxFeePerGas == maxFeePerGas) &&
            (identical(other.maxPriorityFeePerGas, maxPriorityFeePerGas) ||
                other.maxPriorityFeePerGas == maxPriorityFeePerGas) &&
            (identical(other.txFee, txFee) || other.txFee == txFee) &&
            (identical(other.savingFee, savingFee) ||
                other.savingFee == savingFee) &&
            (identical(other.burntFee, burntFee) ||
                other.burntFee == burntFee));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        type,
        status,
        blockNumber,
        blockTimestamp,
        transactionHash,
        transactionIndex,
        fromAddress,
        toAddress,
        value,
        input,
        nonce,
        contractAddress,
        gas,
        gasPrice,
        gasUsed,
        effectiveGasPrice,
        cumulativeGasUsed,
        maxFeePerGas,
        maxPriorityFeePerGas,
        txFee,
        savingFee,
        burntFee
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      __$$TransactionImplCopyWithImpl<_$TransactionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionImplToJson(
      this,
    );
  }
}

abstract class _Transaction implements Transaction {
  const factory _Transaction(
      {required final num type,
      required final num status,
      @JsonKey(name: 'block_number') required final num blockNumber,
      @JsonKey(name: 'block_timestamp') required final DateTime blockTimestamp,
      @JsonKey(name: 'transaction_hash') required final String transactionHash,
      @JsonKey(name: 'transaction_index') required final num transactionIndex,
      @JsonKey(name: 'from_address') required final String fromAddress,
      @JsonKey(name: 'to_address') required final String toAddress,
      required final String value,
      required final String? input,
      required final num nonce,
      @JsonKey(name: 'contract_address') required final String? contractAddress,
      required final num gas,
      @JsonKey(name: 'gas_price') required final num gasPrice,
      @JsonKey(name: 'gas_used') required final num gasUsed,
      @JsonKey(name: 'effective_gas_price')
      required final num effectiveGasPrice,
      @JsonKey(name: 'cumulative_gas_used')
      required final num cumulativeGasUsed,
      @JsonKey(name: 'max_fee_per_gas') required final num? maxFeePerGas,
      @JsonKey(name: 'max_priority_fee_per_gas')
      required final num? maxPriorityFeePerGas,
      @JsonKey(name: 'tx_fee') required final num txFee,
      @JsonKey(name: 'saving_fee') required final num? savingFee,
      @JsonKey(name: 'burnt_fee')
      required final num? burntFee}) = _$TransactionImpl;

  factory _Transaction.fromJson(Map<String, dynamic> json) =
      _$TransactionImpl.fromJson;

  @override
  num get type;
  @override
  num get status;
  @override
  @JsonKey(name: 'block_number')
  num get blockNumber;
  @override
  @JsonKey(name: 'block_timestamp')
  DateTime get blockTimestamp;
  @override
  @JsonKey(name: 'transaction_hash')
  String get transactionHash;
  @override
  @JsonKey(name: 'transaction_index')
  num get transactionIndex;
  @override
  @JsonKey(name: 'from_address')
  String get fromAddress;
  @override
  @JsonKey(name: 'to_address')
  String get toAddress;
  @override
  String get value;
  @override
  String? get input;
  @override
  num get nonce;
  @override
  @JsonKey(name: 'contract_address')
  String? get contractAddress;
  @override
  num get gas;
  @override
  @JsonKey(name: 'gas_price')
  num get gasPrice;
  @override
  @JsonKey(name: 'gas_used')
  num get gasUsed;
  @override
  @JsonKey(name: 'effective_gas_price')
  num get effectiveGasPrice;
  @override
  @JsonKey(name: 'cumulative_gas_used')
  num get cumulativeGasUsed;
  @override
  @JsonKey(name: 'max_fee_per_gas')
  num? get maxFeePerGas;
  @override
  @JsonKey(name: 'max_priority_fee_per_gas')
  num? get maxPriorityFeePerGas;
  @override
  @JsonKey(name: 'tx_fee')
  num get txFee;
  @override
  @JsonKey(name: 'saving_fee')
  num? get savingFee;
  @override
  @JsonKey(name: 'burnt_fee')
  num? get burntFee;
  @override
  @JsonKey(ignore: true)
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
