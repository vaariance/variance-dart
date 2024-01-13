// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

TokenPrice _$TokenPriceFromJson(Map<String, dynamic> json) {
  return _TokenPrice.fromJson(json);
}

/// @nodoc
mixin _$TokenPrice {
  num? get price => throw _privateConstructorUsedError;
  String? get symbol => throw _privateConstructorUsedError;
  num? get decimals => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TokenPriceCopyWith<TokenPrice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenPriceCopyWith<$Res> {
  factory $TokenPriceCopyWith(
          TokenPrice value, $Res Function(TokenPrice) then) =
      _$TokenPriceCopyWithImpl<$Res, TokenPrice>;
  @useResult
  $Res call(
      {num? price,
      String? symbol,
      num? decimals,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$TokenPriceCopyWithImpl<$Res, $Val extends TokenPrice>
    implements $TokenPriceCopyWith<$Res> {
  _$TokenPriceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? price = freezed,
    Object? symbol = freezed,
    Object? decimals = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as num?,
      symbol: freezed == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String?,
      decimals: freezed == decimals
          ? _value.decimals
          : decimals // ignore: cast_nullable_to_non_nullable
              as num?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TokenPriceImplCopyWith<$Res>
    implements $TokenPriceCopyWith<$Res> {
  factory _$$TokenPriceImplCopyWith(
          _$TokenPriceImpl value, $Res Function(_$TokenPriceImpl) then) =
      __$$TokenPriceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {num? price,
      String? symbol,
      num? decimals,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$TokenPriceImplCopyWithImpl<$Res>
    extends _$TokenPriceCopyWithImpl<$Res, _$TokenPriceImpl>
    implements _$$TokenPriceImplCopyWith<$Res> {
  __$$TokenPriceImplCopyWithImpl(
      _$TokenPriceImpl _value, $Res Function(_$TokenPriceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? price = freezed,
    Object? symbol = freezed,
    Object? decimals = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$TokenPriceImpl(
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as num?,
      symbol: freezed == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String?,
      decimals: freezed == decimals
          ? _value.decimals
          : decimals // ignore: cast_nullable_to_non_nullable
              as num?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenPriceImpl implements _TokenPrice {
  const _$TokenPriceImpl(
      {required this.price,
      required this.symbol,
      required this.decimals,
      @JsonKey(name: 'updated_at') required this.updatedAt});

  factory _$TokenPriceImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenPriceImplFromJson(json);

  @override
  final num? price;
  @override
  final String? symbol;
  @override
  final num? decimals;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'TokenPrice(price: $price, symbol: $symbol, decimals: $decimals, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenPriceImpl &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.decimals, decimals) ||
                other.decimals == decimals) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, price, symbol, decimals, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenPriceImplCopyWith<_$TokenPriceImpl> get copyWith =>
      __$$TokenPriceImplCopyWithImpl<_$TokenPriceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenPriceImplToJson(
      this,
    );
  }
}

abstract class _TokenPrice implements TokenPrice {
  const factory _TokenPrice(
          {required final num? price,
          required final String? symbol,
          required final num? decimals,
          @JsonKey(name: 'updated_at') required final DateTime? updatedAt}) =
      _$TokenPriceImpl;

  factory _TokenPrice.fromJson(Map<String, dynamic> json) =
      _$TokenPriceImpl.fromJson;

  @override
  num? get price;
  @override
  String? get symbol;
  @override
  num? get decimals;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$TokenPriceImplCopyWith<_$TokenPriceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
