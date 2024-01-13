// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'metadata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

TokenMetadata _$TokenMetadataFromJson(Map<String, dynamic> json) {
  return _TokenMetadata.fromJson(json);
}

/// @nodoc
mixin _$TokenMetadata {
  @JsonKey(name: 'contract_address')
  String get contractAddress => throw _privateConstructorUsedError;
  num get decimals => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get symbol => throw _privateConstructorUsedError;
  @BigIntConverter()
  @JsonKey(name: 'total_supply')
  Uint256 get totalSupply => throw _privateConstructorUsedError;
  List<TokenLogo>? get logos => throw _privateConstructorUsedError;
  List<TokenUrl>? get urls => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_usd_price')
  num? get currentUsdPrice => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TokenMetadataCopyWith<TokenMetadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenMetadataCopyWith<$Res> {
  factory $TokenMetadataCopyWith(
          TokenMetadata value, $Res Function(TokenMetadata) then) =
      _$TokenMetadataCopyWithImpl<$Res, TokenMetadata>;
  @useResult
  $Res call(
      {@JsonKey(name: 'contract_address') String contractAddress,
      num decimals,
      String name,
      String symbol,
      @BigIntConverter() @JsonKey(name: 'total_supply') Uint256 totalSupply,
      List<TokenLogo>? logos,
      List<TokenUrl>? urls,
      @JsonKey(name: 'current_usd_price') num? currentUsdPrice});
}

/// @nodoc
class _$TokenMetadataCopyWithImpl<$Res, $Val extends TokenMetadata>
    implements $TokenMetadataCopyWith<$Res> {
  _$TokenMetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contractAddress = null,
    Object? decimals = null,
    Object? name = null,
    Object? symbol = null,
    Object? totalSupply = null,
    Object? logos = freezed,
    Object? urls = freezed,
    Object? currentUsdPrice = freezed,
  }) {
    return _then(_value.copyWith(
      contractAddress: null == contractAddress
          ? _value.contractAddress
          : contractAddress // ignore: cast_nullable_to_non_nullable
              as String,
      decimals: null == decimals
          ? _value.decimals
          : decimals // ignore: cast_nullable_to_non_nullable
              as num,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      totalSupply: null == totalSupply
          ? _value.totalSupply
          : totalSupply // ignore: cast_nullable_to_non_nullable
              as Uint256,
      logos: freezed == logos
          ? _value.logos
          : logos // ignore: cast_nullable_to_non_nullable
              as List<TokenLogo>?,
      urls: freezed == urls
          ? _value.urls
          : urls // ignore: cast_nullable_to_non_nullable
              as List<TokenUrl>?,
      currentUsdPrice: freezed == currentUsdPrice
          ? _value.currentUsdPrice
          : currentUsdPrice // ignore: cast_nullable_to_non_nullable
              as num?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TokenMetadataImplCopyWith<$Res>
    implements $TokenMetadataCopyWith<$Res> {
  factory _$$TokenMetadataImplCopyWith(
          _$TokenMetadataImpl value, $Res Function(_$TokenMetadataImpl) then) =
      __$$TokenMetadataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'contract_address') String contractAddress,
      num decimals,
      String name,
      String symbol,
      @BigIntConverter() @JsonKey(name: 'total_supply') Uint256 totalSupply,
      List<TokenLogo>? logos,
      List<TokenUrl>? urls,
      @JsonKey(name: 'current_usd_price') num? currentUsdPrice});
}

/// @nodoc
class __$$TokenMetadataImplCopyWithImpl<$Res>
    extends _$TokenMetadataCopyWithImpl<$Res, _$TokenMetadataImpl>
    implements _$$TokenMetadataImplCopyWith<$Res> {
  __$$TokenMetadataImplCopyWithImpl(
      _$TokenMetadataImpl _value, $Res Function(_$TokenMetadataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contractAddress = null,
    Object? decimals = null,
    Object? name = null,
    Object? symbol = null,
    Object? totalSupply = null,
    Object? logos = freezed,
    Object? urls = freezed,
    Object? currentUsdPrice = freezed,
  }) {
    return _then(_$TokenMetadataImpl(
      contractAddress: null == contractAddress
          ? _value.contractAddress
          : contractAddress // ignore: cast_nullable_to_non_nullable
              as String,
      decimals: null == decimals
          ? _value.decimals
          : decimals // ignore: cast_nullable_to_non_nullable
              as num,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      totalSupply: null == totalSupply
          ? _value.totalSupply
          : totalSupply // ignore: cast_nullable_to_non_nullable
              as Uint256,
      logos: freezed == logos
          ? _value._logos
          : logos // ignore: cast_nullable_to_non_nullable
              as List<TokenLogo>?,
      urls: freezed == urls
          ? _value._urls
          : urls // ignore: cast_nullable_to_non_nullable
              as List<TokenUrl>?,
      currentUsdPrice: freezed == currentUsdPrice
          ? _value.currentUsdPrice
          : currentUsdPrice // ignore: cast_nullable_to_non_nullable
              as num?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenMetadataImpl implements _TokenMetadata {
  const _$TokenMetadataImpl(
      {@JsonKey(name: 'contract_address') required this.contractAddress,
      required this.decimals,
      required this.name,
      required this.symbol,
      @BigIntConverter()
      @JsonKey(name: 'total_supply')
      required this.totalSupply,
      required final List<TokenLogo>? logos,
      required final List<TokenUrl>? urls,
      @JsonKey(name: 'current_usd_price') required this.currentUsdPrice})
      : _logos = logos,
        _urls = urls;

  factory _$TokenMetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenMetadataImplFromJson(json);

  @override
  @JsonKey(name: 'contract_address')
  final String contractAddress;
  @override
  final num decimals;
  @override
  final String name;
  @override
  final String symbol;
  @override
  @BigIntConverter()
  @JsonKey(name: 'total_supply')
  final Uint256 totalSupply;
  final List<TokenLogo>? _logos;
  @override
  List<TokenLogo>? get logos {
    final value = _logos;
    if (value == null) return null;
    if (_logos is EqualUnmodifiableListView) return _logos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

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
  @JsonKey(name: 'current_usd_price')
  final num? currentUsdPrice;

  @override
  String toString() {
    return 'TokenMetadata(contractAddress: $contractAddress, decimals: $decimals, name: $name, symbol: $symbol, totalSupply: $totalSupply, logos: $logos, urls: $urls, currentUsdPrice: $currentUsdPrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenMetadataImpl &&
            (identical(other.contractAddress, contractAddress) ||
                other.contractAddress == contractAddress) &&
            (identical(other.decimals, decimals) ||
                other.decimals == decimals) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.totalSupply, totalSupply) ||
                other.totalSupply == totalSupply) &&
            const DeepCollectionEquality().equals(other._logos, _logos) &&
            const DeepCollectionEquality().equals(other._urls, _urls) &&
            (identical(other.currentUsdPrice, currentUsdPrice) ||
                other.currentUsdPrice == currentUsdPrice));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      contractAddress,
      decimals,
      name,
      symbol,
      totalSupply,
      const DeepCollectionEquality().hash(_logos),
      const DeepCollectionEquality().hash(_urls),
      currentUsdPrice);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenMetadataImplCopyWith<_$TokenMetadataImpl> get copyWith =>
      __$$TokenMetadataImplCopyWithImpl<_$TokenMetadataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenMetadataImplToJson(
      this,
    );
  }
}

abstract class _TokenMetadata implements TokenMetadata {
  const factory _TokenMetadata(
      {@JsonKey(name: 'contract_address') required final String contractAddress,
      required final num decimals,
      required final String name,
      required final String symbol,
      @BigIntConverter()
      @JsonKey(name: 'total_supply')
      required final Uint256 totalSupply,
      required final List<TokenLogo>? logos,
      required final List<TokenUrl>? urls,
      @JsonKey(name: 'current_usd_price')
      required final num? currentUsdPrice}) = _$TokenMetadataImpl;

  factory _TokenMetadata.fromJson(Map<String, dynamic> json) =
      _$TokenMetadataImpl.fromJson;

  @override
  @JsonKey(name: 'contract_address')
  String get contractAddress;
  @override
  num get decimals;
  @override
  String get name;
  @override
  String get symbol;
  @override
  @BigIntConverter()
  @JsonKey(name: 'total_supply')
  Uint256 get totalSupply;
  @override
  List<TokenLogo>? get logos;
  @override
  List<TokenUrl>? get urls;
  @override
  @JsonKey(name: 'current_usd_price')
  num? get currentUsdPrice;
  @override
  @JsonKey(ignore: true)
  _$$TokenMetadataImplCopyWith<_$TokenMetadataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
