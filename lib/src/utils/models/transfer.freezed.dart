// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transfer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

TokenTransfer _$TokenTransferFromJson(Map<String, dynamic> json) {
  return _TokenTransfer.fromJson(json);
}

/// @nodoc
mixin _$TokenTransfer {
  @JsonKey(name: 'block_number')
  num get blockNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'block_timestamp')
  DateTime get blockTimestamp => throw _privateConstructorUsedError;
  @JsonKey(name: 'contract_address')
  String get contractAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'from_address')
  String get fromAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'log_index')
  num get logIndex => throw _privateConstructorUsedError;
  @JsonKey(name: 'to_address')
  String get toAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_hash')
  String get transactionHash => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_index')
  num get transactionIndex => throw _privateConstructorUsedError;
  @JsonKey(name: 'tx_fee')
  num get txFee => throw _privateConstructorUsedError;
  @JsonKey(name: 'tx_type')
  num get txType => throw _privateConstructorUsedError;
  @BigIntConverter()
  Uint256 get value => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TokenTransferCopyWith<TokenTransfer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenTransferCopyWith<$Res> {
  factory $TokenTransferCopyWith(
          TokenTransfer value, $Res Function(TokenTransfer) then) =
      _$TokenTransferCopyWithImpl<$Res, TokenTransfer>;
  @useResult
  $Res call(
      {@JsonKey(name: 'block_number') num blockNumber,
      @JsonKey(name: 'block_timestamp') DateTime blockTimestamp,
      @JsonKey(name: 'contract_address') String contractAddress,
      @JsonKey(name: 'from_address') String fromAddress,
      @JsonKey(name: 'log_index') num logIndex,
      @JsonKey(name: 'to_address') String toAddress,
      @JsonKey(name: 'transaction_hash') String transactionHash,
      @JsonKey(name: 'transaction_index') num transactionIndex,
      @JsonKey(name: 'tx_fee') num txFee,
      @JsonKey(name: 'tx_type') num txType,
      @BigIntConverter() Uint256 value});
}

/// @nodoc
class _$TokenTransferCopyWithImpl<$Res, $Val extends TokenTransfer>
    implements $TokenTransferCopyWith<$Res> {
  _$TokenTransferCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? blockNumber = null,
    Object? blockTimestamp = null,
    Object? contractAddress = null,
    Object? fromAddress = null,
    Object? logIndex = null,
    Object? toAddress = null,
    Object? transactionHash = null,
    Object? transactionIndex = null,
    Object? txFee = null,
    Object? txType = null,
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      blockNumber: null == blockNumber
          ? _value.blockNumber
          : blockNumber // ignore: cast_nullable_to_non_nullable
              as num,
      blockTimestamp: null == blockTimestamp
          ? _value.blockTimestamp
          : blockTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      contractAddress: null == contractAddress
          ? _value.contractAddress
          : contractAddress // ignore: cast_nullable_to_non_nullable
              as String,
      fromAddress: null == fromAddress
          ? _value.fromAddress
          : fromAddress // ignore: cast_nullable_to_non_nullable
              as String,
      logIndex: null == logIndex
          ? _value.logIndex
          : logIndex // ignore: cast_nullable_to_non_nullable
              as num,
      toAddress: null == toAddress
          ? _value.toAddress
          : toAddress // ignore: cast_nullable_to_non_nullable
              as String,
      transactionHash: null == transactionHash
          ? _value.transactionHash
          : transactionHash // ignore: cast_nullable_to_non_nullable
              as String,
      transactionIndex: null == transactionIndex
          ? _value.transactionIndex
          : transactionIndex // ignore: cast_nullable_to_non_nullable
              as num,
      txFee: null == txFee
          ? _value.txFee
          : txFee // ignore: cast_nullable_to_non_nullable
              as num,
      txType: null == txType
          ? _value.txType
          : txType // ignore: cast_nullable_to_non_nullable
              as num,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as Uint256,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TokenTransferImplCopyWith<$Res>
    implements $TokenTransferCopyWith<$Res> {
  factory _$$TokenTransferImplCopyWith(
          _$TokenTransferImpl value, $Res Function(_$TokenTransferImpl) then) =
      __$$TokenTransferImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'block_number') num blockNumber,
      @JsonKey(name: 'block_timestamp') DateTime blockTimestamp,
      @JsonKey(name: 'contract_address') String contractAddress,
      @JsonKey(name: 'from_address') String fromAddress,
      @JsonKey(name: 'log_index') num logIndex,
      @JsonKey(name: 'to_address') String toAddress,
      @JsonKey(name: 'transaction_hash') String transactionHash,
      @JsonKey(name: 'transaction_index') num transactionIndex,
      @JsonKey(name: 'tx_fee') num txFee,
      @JsonKey(name: 'tx_type') num txType,
      @BigIntConverter() Uint256 value});
}

/// @nodoc
class __$$TokenTransferImplCopyWithImpl<$Res>
    extends _$TokenTransferCopyWithImpl<$Res, _$TokenTransferImpl>
    implements _$$TokenTransferImplCopyWith<$Res> {
  __$$TokenTransferImplCopyWithImpl(
      _$TokenTransferImpl _value, $Res Function(_$TokenTransferImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? blockNumber = null,
    Object? blockTimestamp = null,
    Object? contractAddress = null,
    Object? fromAddress = null,
    Object? logIndex = null,
    Object? toAddress = null,
    Object? transactionHash = null,
    Object? transactionIndex = null,
    Object? txFee = null,
    Object? txType = null,
    Object? value = null,
  }) {
    return _then(_$TokenTransferImpl(
      blockNumber: null == blockNumber
          ? _value.blockNumber
          : blockNumber // ignore: cast_nullable_to_non_nullable
              as num,
      blockTimestamp: null == blockTimestamp
          ? _value.blockTimestamp
          : blockTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      contractAddress: null == contractAddress
          ? _value.contractAddress
          : contractAddress // ignore: cast_nullable_to_non_nullable
              as String,
      fromAddress: null == fromAddress
          ? _value.fromAddress
          : fromAddress // ignore: cast_nullable_to_non_nullable
              as String,
      logIndex: null == logIndex
          ? _value.logIndex
          : logIndex // ignore: cast_nullable_to_non_nullable
              as num,
      toAddress: null == toAddress
          ? _value.toAddress
          : toAddress // ignore: cast_nullable_to_non_nullable
              as String,
      transactionHash: null == transactionHash
          ? _value.transactionHash
          : transactionHash // ignore: cast_nullable_to_non_nullable
              as String,
      transactionIndex: null == transactionIndex
          ? _value.transactionIndex
          : transactionIndex // ignore: cast_nullable_to_non_nullable
              as num,
      txFee: null == txFee
          ? _value.txFee
          : txFee // ignore: cast_nullable_to_non_nullable
              as num,
      txType: null == txType
          ? _value.txType
          : txType // ignore: cast_nullable_to_non_nullable
              as num,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as Uint256,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenTransferImpl extends _TokenTransfer {
  const _$TokenTransferImpl(
      {@JsonKey(name: 'block_number') required this.blockNumber,
      @JsonKey(name: 'block_timestamp') required this.blockTimestamp,
      @JsonKey(name: 'contract_address') required this.contractAddress,
      @JsonKey(name: 'from_address') required this.fromAddress,
      @JsonKey(name: 'log_index') required this.logIndex,
      @JsonKey(name: 'to_address') required this.toAddress,
      @JsonKey(name: 'transaction_hash') required this.transactionHash,
      @JsonKey(name: 'transaction_index') required this.transactionIndex,
      @JsonKey(name: 'tx_fee') required this.txFee,
      @JsonKey(name: 'tx_type') required this.txType,
      @BigIntConverter() required this.value})
      : super._();

  factory _$TokenTransferImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenTransferImplFromJson(json);

  @override
  @JsonKey(name: 'block_number')
  final num blockNumber;
  @override
  @JsonKey(name: 'block_timestamp')
  final DateTime blockTimestamp;
  @override
  @JsonKey(name: 'contract_address')
  final String contractAddress;
  @override
  @JsonKey(name: 'from_address')
  final String fromAddress;
  @override
  @JsonKey(name: 'log_index')
  final num logIndex;
  @override
  @JsonKey(name: 'to_address')
  final String toAddress;
  @override
  @JsonKey(name: 'transaction_hash')
  final String transactionHash;
  @override
  @JsonKey(name: 'transaction_index')
  final num transactionIndex;
  @override
  @JsonKey(name: 'tx_fee')
  final num txFee;
  @override
  @JsonKey(name: 'tx_type')
  final num txType;
  @override
  @BigIntConverter()
  final Uint256 value;

  @override
  String toString() {
    return 'TokenTransfer(blockNumber: $blockNumber, blockTimestamp: $blockTimestamp, contractAddress: $contractAddress, fromAddress: $fromAddress, logIndex: $logIndex, toAddress: $toAddress, transactionHash: $transactionHash, transactionIndex: $transactionIndex, txFee: $txFee, txType: $txType, value: $value)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenTransferImpl &&
            (identical(other.blockNumber, blockNumber) ||
                other.blockNumber == blockNumber) &&
            (identical(other.blockTimestamp, blockTimestamp) ||
                other.blockTimestamp == blockTimestamp) &&
            (identical(other.contractAddress, contractAddress) ||
                other.contractAddress == contractAddress) &&
            (identical(other.fromAddress, fromAddress) ||
                other.fromAddress == fromAddress) &&
            (identical(other.logIndex, logIndex) ||
                other.logIndex == logIndex) &&
            (identical(other.toAddress, toAddress) ||
                other.toAddress == toAddress) &&
            (identical(other.transactionHash, transactionHash) ||
                other.transactionHash == transactionHash) &&
            (identical(other.transactionIndex, transactionIndex) ||
                other.transactionIndex == transactionIndex) &&
            (identical(other.txFee, txFee) || other.txFee == txFee) &&
            (identical(other.txType, txType) || other.txType == txType) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      blockNumber,
      blockTimestamp,
      contractAddress,
      fromAddress,
      logIndex,
      toAddress,
      transactionHash,
      transactionIndex,
      txFee,
      txType,
      value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenTransferImplCopyWith<_$TokenTransferImpl> get copyWith =>
      __$$TokenTransferImplCopyWithImpl<_$TokenTransferImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenTransferImplToJson(
      this,
    );
  }
}

abstract class _TokenTransfer extends TokenTransfer {
  const factory _TokenTransfer(
      {@JsonKey(name: 'block_number') required final num blockNumber,
      @JsonKey(name: 'block_timestamp') required final DateTime blockTimestamp,
      @JsonKey(name: 'contract_address') required final String contractAddress,
      @JsonKey(name: 'from_address') required final String fromAddress,
      @JsonKey(name: 'log_index') required final num logIndex,
      @JsonKey(name: 'to_address') required final String toAddress,
      @JsonKey(name: 'transaction_hash') required final String transactionHash,
      @JsonKey(name: 'transaction_index') required final num transactionIndex,
      @JsonKey(name: 'tx_fee') required final num txFee,
      @JsonKey(name: 'tx_type') required final num txType,
      @BigIntConverter() required final Uint256 value}) = _$TokenTransferImpl;
  const _TokenTransfer._() : super._();

  factory _TokenTransfer.fromJson(Map<String, dynamic> json) =
      _$TokenTransferImpl.fromJson;

  @override
  @JsonKey(name: 'block_number')
  num get blockNumber;
  @override
  @JsonKey(name: 'block_timestamp')
  DateTime get blockTimestamp;
  @override
  @JsonKey(name: 'contract_address')
  String get contractAddress;
  @override
  @JsonKey(name: 'from_address')
  String get fromAddress;
  @override
  @JsonKey(name: 'log_index')
  num get logIndex;
  @override
  @JsonKey(name: 'to_address')
  String get toAddress;
  @override
  @JsonKey(name: 'transaction_hash')
  String get transactionHash;
  @override
  @JsonKey(name: 'transaction_index')
  num get transactionIndex;
  @override
  @JsonKey(name: 'tx_fee')
  num get txFee;
  @override
  @JsonKey(name: 'tx_type')
  num get txType;
  @override
  @BigIntConverter()
  Uint256 get value;
  @override
  @JsonKey(ignore: true)
  _$$TokenTransferImplCopyWith<_$TokenTransferImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
