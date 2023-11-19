// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Token _$TokenFromJson(Map<String, dynamic> json) {
  return _Token.fromJson(json);
}

/// @nodoc
mixin _$Token {
  @HexConverter()
  Uint256 get balance => throw _privateConstructorUsedError;
  @JsonKey(name: 'contract_address')
  String get contractAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_usd_price')
  num? get currentUsdPrice => throw _privateConstructorUsedError;
  num get decimals => throw _privateConstructorUsedError;
  List<TokenLogo>? get logos => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get symbol => throw _privateConstructorUsedError;
  @BigIntConverter()
  @JsonKey(name: 'total_supply')
  Uint256? get totalSupply => throw _privateConstructorUsedError;
  List<TokenUrl>? get urls => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TokenCopyWith<Token> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenCopyWith<$Res> {
  factory $TokenCopyWith(Token value, $Res Function(Token) then) =
      _$TokenCopyWithImpl<$Res, Token>;
  @useResult
  $Res call(
      {@HexConverter() Uint256 balance,
      @JsonKey(name: 'contract_address') String contractAddress,
      @JsonKey(name: 'current_usd_price') num? currentUsdPrice,
      num decimals,
      List<TokenLogo>? logos,
      String name,
      String symbol,
      @BigIntConverter() @JsonKey(name: 'total_supply') Uint256? totalSupply,
      List<TokenUrl>? urls});
}

/// @nodoc
class _$TokenCopyWithImpl<$Res, $Val extends Token>
    implements $TokenCopyWith<$Res> {
  _$TokenCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? balance = null,
    Object? contractAddress = null,
    Object? currentUsdPrice = freezed,
    Object? decimals = null,
    Object? logos = freezed,
    Object? name = null,
    Object? symbol = null,
    Object? totalSupply = freezed,
    Object? urls = freezed,
  }) {
    return _then(_value.copyWith(
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as Uint256,
      contractAddress: null == contractAddress
          ? _value.contractAddress
          : contractAddress // ignore: cast_nullable_to_non_nullable
              as String,
      currentUsdPrice: freezed == currentUsdPrice
          ? _value.currentUsdPrice
          : currentUsdPrice // ignore: cast_nullable_to_non_nullable
              as num?,
      decimals: null == decimals
          ? _value.decimals
          : decimals // ignore: cast_nullable_to_non_nullable
              as num,
      logos: freezed == logos
          ? _value.logos
          : logos // ignore: cast_nullable_to_non_nullable
              as List<TokenLogo>?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      totalSupply: freezed == totalSupply
          ? _value.totalSupply
          : totalSupply // ignore: cast_nullable_to_non_nullable
              as Uint256?,
      urls: freezed == urls
          ? _value.urls
          : urls // ignore: cast_nullable_to_non_nullable
              as List<TokenUrl>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TokenImplCopyWith<$Res> implements $TokenCopyWith<$Res> {
  factory _$$TokenImplCopyWith(
          _$TokenImpl value, $Res Function(_$TokenImpl) then) =
      __$$TokenImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HexConverter() Uint256 balance,
      @JsonKey(name: 'contract_address') String contractAddress,
      @JsonKey(name: 'current_usd_price') num? currentUsdPrice,
      num decimals,
      List<TokenLogo>? logos,
      String name,
      String symbol,
      @BigIntConverter() @JsonKey(name: 'total_supply') Uint256? totalSupply,
      List<TokenUrl>? urls});
}

/// @nodoc
class __$$TokenImplCopyWithImpl<$Res>
    extends _$TokenCopyWithImpl<$Res, _$TokenImpl>
    implements _$$TokenImplCopyWith<$Res> {
  __$$TokenImplCopyWithImpl(
      _$TokenImpl _value, $Res Function(_$TokenImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? balance = null,
    Object? contractAddress = null,
    Object? currentUsdPrice = freezed,
    Object? decimals = null,
    Object? logos = freezed,
    Object? name = null,
    Object? symbol = null,
    Object? totalSupply = freezed,
    Object? urls = freezed,
  }) {
    return _then(_$TokenImpl(
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as Uint256,
      contractAddress: null == contractAddress
          ? _value.contractAddress
          : contractAddress // ignore: cast_nullable_to_non_nullable
              as String,
      currentUsdPrice: freezed == currentUsdPrice
          ? _value.currentUsdPrice
          : currentUsdPrice // ignore: cast_nullable_to_non_nullable
              as num?,
      decimals: null == decimals
          ? _value.decimals
          : decimals // ignore: cast_nullable_to_non_nullable
              as num,
      logos: freezed == logos
          ? _value._logos
          : logos // ignore: cast_nullable_to_non_nullable
              as List<TokenLogo>?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      totalSupply: freezed == totalSupply
          ? _value.totalSupply
          : totalSupply // ignore: cast_nullable_to_non_nullable
              as Uint256?,
      urls: freezed == urls
          ? _value._urls
          : urls // ignore: cast_nullable_to_non_nullable
              as List<TokenUrl>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenImpl implements _Token {
  const _$TokenImpl(
      {@HexConverter() required this.balance,
      @JsonKey(name: 'contract_address') required this.contractAddress,
      @JsonKey(name: 'current_usd_price') required this.currentUsdPrice,
      required this.decimals,
      required final List<TokenLogo>? logos,
      required this.name,
      required this.symbol,
      @BigIntConverter()
      @JsonKey(name: 'total_supply')
      required this.totalSupply,
      required final List<TokenUrl>? urls})
      : _logos = logos,
        _urls = urls;

  factory _$TokenImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenImplFromJson(json);

  @override
  @HexConverter()
  final Uint256 balance;
  @override
  @JsonKey(name: 'contract_address')
  final String contractAddress;
  @override
  @JsonKey(name: 'current_usd_price')
  final num? currentUsdPrice;
  @override
  final num decimals;
  final List<TokenLogo>? _logos;
  @override
  List<TokenLogo>? get logos {
    final value = _logos;
    if (value == null) return null;
    if (_logos is EqualUnmodifiableListView) return _logos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String name;
  @override
  final String symbol;
  @override
  @BigIntConverter()
  @JsonKey(name: 'total_supply')
  final Uint256? totalSupply;
  final List<TokenUrl>? _urls;
  @override
  List<TokenUrl>? get urls {
    final value = _urls;
    if (value == null) return null;
    if (_urls is EqualUnmodifiableListView) return _urls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Token(balance: $balance, contractAddress: $contractAddress, currentUsdPrice: $currentUsdPrice, decimals: $decimals, logos: $logos, name: $name, symbol: $symbol, totalSupply: $totalSupply, urls: $urls)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenImpl &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.contractAddress, contractAddress) ||
                other.contractAddress == contractAddress) &&
            (identical(other.currentUsdPrice, currentUsdPrice) ||
                other.currentUsdPrice == currentUsdPrice) &&
            (identical(other.decimals, decimals) ||
                other.decimals == decimals) &&
            const DeepCollectionEquality().equals(other._logos, _logos) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.totalSupply, totalSupply) ||
                other.totalSupply == totalSupply) &&
            const DeepCollectionEquality().equals(other._urls, _urls));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      balance,
      contractAddress,
      currentUsdPrice,
      decimals,
      const DeepCollectionEquality().hash(_logos),
      name,
      symbol,
      totalSupply,
      const DeepCollectionEquality().hash(_urls));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenImplCopyWith<_$TokenImpl> get copyWith =>
      __$$TokenImplCopyWithImpl<_$TokenImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenImplToJson(
      this,
    );
  }
}

abstract class _Token implements Token {
  const factory _Token(
      {@HexConverter() required final Uint256 balance,
      @JsonKey(name: 'contract_address') required final String contractAddress,
      @JsonKey(name: 'current_usd_price') required final num? currentUsdPrice,
      required final num decimals,
      required final List<TokenLogo>? logos,
      required final String name,
      required final String symbol,
      @BigIntConverter()
      @JsonKey(name: 'total_supply')
      required final Uint256? totalSupply,
      required final List<TokenUrl>? urls}) = _$TokenImpl;

  factory _Token.fromJson(Map<String, dynamic> json) = _$TokenImpl.fromJson;

  @override
  @HexConverter()
  Uint256 get balance;
  @override
  @JsonKey(name: 'contract_address')
  String get contractAddress;
  @override
  @JsonKey(name: 'current_usd_price')
  num? get currentUsdPrice;
  @override
  num get decimals;
  @override
  List<TokenLogo>? get logos;
  @override
  String get name;
  @override
  String get symbol;
  @override
  @BigIntConverter()
  @JsonKey(name: 'total_supply')
  Uint256? get totalSupply;
  @override
  List<TokenUrl>? get urls;
  @override
  @JsonKey(ignore: true)
  _$$TokenImplCopyWith<_$TokenImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
