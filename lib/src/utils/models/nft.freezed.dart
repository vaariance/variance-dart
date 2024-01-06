// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

NFT _$NFTFromJson(Map<String, dynamic> json) {
  return _NFT.fromJson(json);
}

/// @nodoc
mixin _$NFT {
  @JsonKey(name: 'contract_address')
  String get contractAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'erc_type')
  String? get ercType => throw _privateConstructorUsedError;
  @JsonKey(name: 'floor_prices')
  List<NFTFloorPrice>? get floorPrices => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_uri')
  String? get imageUri => throw _privateConstructorUsedError;
  NFTMetadata? get metadata => throw _privateConstructorUsedError;
  @JsonKey(name: 'mint_time')
  DateTime get mintTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'mint_transaction_hash')
  String get mintTransactionHash => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get owner => throw _privateConstructorUsedError;
  @JsonKey(name: 'rarity_rank')
  num? get rarityRank => throw _privateConstructorUsedError;
  @JsonKey(name: 'rarity_score')
  num? get rarityScore => throw _privateConstructorUsedError;
  String get symbol => throw _privateConstructorUsedError;
  @JsonKey(name: 'token_id')
  String get tokenId => throw _privateConstructorUsedError;
  @JsonKey(name: 'token_uri')
  String? get tokenUri => throw _privateConstructorUsedError;
  num? get total => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_string')
  String? get totalString => throw _privateConstructorUsedError;
  List<NFTAttributes>? get traits => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NFTCopyWith<NFT> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NFTCopyWith<$Res> {
  factory $NFTCopyWith(NFT value, $Res Function(NFT) then) =
      _$NFTCopyWithImpl<$Res, NFT>;
  @useResult
  $Res call(
      {@JsonKey(name: 'contract_address') String contractAddress,
      @JsonKey(name: 'erc_type') String? ercType,
      @JsonKey(name: 'floor_prices') List<NFTFloorPrice>? floorPrices,
      @JsonKey(name: 'image_uri') String? imageUri,
      NFTMetadata? metadata,
      @JsonKey(name: 'mint_time') DateTime mintTime,
      @JsonKey(name: 'mint_transaction_hash') String mintTransactionHash,
      String? name,
      String? owner,
      @JsonKey(name: 'rarity_rank') num? rarityRank,
      @JsonKey(name: 'rarity_score') num? rarityScore,
      String symbol,
      @JsonKey(name: 'token_id') String tokenId,
      @JsonKey(name: 'token_uri') String? tokenUri,
      num? total,
      @JsonKey(name: 'total_string') String? totalString,
      List<NFTAttributes>? traits});
}

/// @nodoc
class _$NFTCopyWithImpl<$Res, $Val extends NFT> implements $NFTCopyWith<$Res> {
  _$NFTCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contractAddress = null,
    Object? ercType = freezed,
    Object? floorPrices = freezed,
    Object? imageUri = freezed,
    Object? metadata = freezed,
    Object? mintTime = null,
    Object? mintTransactionHash = null,
    Object? name = freezed,
    Object? owner = freezed,
    Object? rarityRank = freezed,
    Object? rarityScore = freezed,
    Object? symbol = null,
    Object? tokenId = null,
    Object? tokenUri = freezed,
    Object? total = freezed,
    Object? totalString = freezed,
    Object? traits = freezed,
  }) {
    return _then(_value.copyWith(
      contractAddress: null == contractAddress
          ? _value.contractAddress
          : contractAddress // ignore: cast_nullable_to_non_nullable
              as String,
      ercType: freezed == ercType
          ? _value.ercType
          : ercType // ignore: cast_nullable_to_non_nullable
              as String?,
      floorPrices: freezed == floorPrices
          ? _value.floorPrices
          : floorPrices // ignore: cast_nullable_to_non_nullable
              as List<NFTFloorPrice>?,
      imageUri: freezed == imageUri
          ? _value.imageUri
          : imageUri // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as NFTMetadata?,
      mintTime: null == mintTime
          ? _value.mintTime
          : mintTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      mintTransactionHash: null == mintTransactionHash
          ? _value.mintTransactionHash
          : mintTransactionHash // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      owner: freezed == owner
          ? _value.owner
          : owner // ignore: cast_nullable_to_non_nullable
              as String?,
      rarityRank: freezed == rarityRank
          ? _value.rarityRank
          : rarityRank // ignore: cast_nullable_to_non_nullable
              as num?,
      rarityScore: freezed == rarityScore
          ? _value.rarityScore
          : rarityScore // ignore: cast_nullable_to_non_nullable
              as num?,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      tokenId: null == tokenId
          ? _value.tokenId
          : tokenId // ignore: cast_nullable_to_non_nullable
              as String,
      tokenUri: freezed == tokenUri
          ? _value.tokenUri
          : tokenUri // ignore: cast_nullable_to_non_nullable
              as String?,
      total: freezed == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as num?,
      totalString: freezed == totalString
          ? _value.totalString
          : totalString // ignore: cast_nullable_to_non_nullable
              as String?,
      traits: freezed == traits
          ? _value.traits
          : traits // ignore: cast_nullable_to_non_nullable
              as List<NFTAttributes>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NFTImplCopyWith<$Res> implements $NFTCopyWith<$Res> {
  factory _$$NFTImplCopyWith(_$NFTImpl value, $Res Function(_$NFTImpl) then) =
      __$$NFTImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'contract_address') String contractAddress,
      @JsonKey(name: 'erc_type') String? ercType,
      @JsonKey(name: 'floor_prices') List<NFTFloorPrice>? floorPrices,
      @JsonKey(name: 'image_uri') String? imageUri,
      NFTMetadata? metadata,
      @JsonKey(name: 'mint_time') DateTime mintTime,
      @JsonKey(name: 'mint_transaction_hash') String mintTransactionHash,
      String? name,
      String? owner,
      @JsonKey(name: 'rarity_rank') num? rarityRank,
      @JsonKey(name: 'rarity_score') num? rarityScore,
      String symbol,
      @JsonKey(name: 'token_id') String tokenId,
      @JsonKey(name: 'token_uri') String? tokenUri,
      num? total,
      @JsonKey(name: 'total_string') String? totalString,
      List<NFTAttributes>? traits});
}

/// @nodoc
class __$$NFTImplCopyWithImpl<$Res> extends _$NFTCopyWithImpl<$Res, _$NFTImpl>
    implements _$$NFTImplCopyWith<$Res> {
  __$$NFTImplCopyWithImpl(_$NFTImpl _value, $Res Function(_$NFTImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contractAddress = null,
    Object? ercType = freezed,
    Object? floorPrices = freezed,
    Object? imageUri = freezed,
    Object? metadata = freezed,
    Object? mintTime = null,
    Object? mintTransactionHash = null,
    Object? name = freezed,
    Object? owner = freezed,
    Object? rarityRank = freezed,
    Object? rarityScore = freezed,
    Object? symbol = null,
    Object? tokenId = null,
    Object? tokenUri = freezed,
    Object? total = freezed,
    Object? totalString = freezed,
    Object? traits = freezed,
  }) {
    return _then(_$NFTImpl(
      contractAddress: null == contractAddress
          ? _value.contractAddress
          : contractAddress // ignore: cast_nullable_to_non_nullable
              as String,
      ercType: freezed == ercType
          ? _value.ercType
          : ercType // ignore: cast_nullable_to_non_nullable
              as String?,
      floorPrices: freezed == floorPrices
          ? _value._floorPrices
          : floorPrices // ignore: cast_nullable_to_non_nullable
              as List<NFTFloorPrice>?,
      imageUri: freezed == imageUri
          ? _value.imageUri
          : imageUri // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as NFTMetadata?,
      mintTime: null == mintTime
          ? _value.mintTime
          : mintTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      mintTransactionHash: null == mintTransactionHash
          ? _value.mintTransactionHash
          : mintTransactionHash // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      owner: freezed == owner
          ? _value.owner
          : owner // ignore: cast_nullable_to_non_nullable
              as String?,
      rarityRank: freezed == rarityRank
          ? _value.rarityRank
          : rarityRank // ignore: cast_nullable_to_non_nullable
              as num?,
      rarityScore: freezed == rarityScore
          ? _value.rarityScore
          : rarityScore // ignore: cast_nullable_to_non_nullable
              as num?,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      tokenId: null == tokenId
          ? _value.tokenId
          : tokenId // ignore: cast_nullable_to_non_nullable
              as String,
      tokenUri: freezed == tokenUri
          ? _value.tokenUri
          : tokenUri // ignore: cast_nullable_to_non_nullable
              as String?,
      total: freezed == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as num?,
      totalString: freezed == totalString
          ? _value.totalString
          : totalString // ignore: cast_nullable_to_non_nullable
              as String?,
      traits: freezed == traits
          ? _value._traits
          : traits // ignore: cast_nullable_to_non_nullable
              as List<NFTAttributes>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NFTImpl implements _NFT {
  const _$NFTImpl(
      {@JsonKey(name: 'contract_address') required this.contractAddress,
      @JsonKey(name: 'erc_type') required this.ercType,
      @JsonKey(name: 'floor_prices')
      required final List<NFTFloorPrice>? floorPrices,
      @JsonKey(name: 'image_uri') required this.imageUri,
      required this.metadata,
      @JsonKey(name: 'mint_time') required this.mintTime,
      @JsonKey(name: 'mint_transaction_hash') required this.mintTransactionHash,
      required this.name,
      required this.owner,
      @JsonKey(name: 'rarity_rank') required this.rarityRank,
      @JsonKey(name: 'rarity_score') required this.rarityScore,
      required this.symbol,
      @JsonKey(name: 'token_id') required this.tokenId,
      @JsonKey(name: 'token_uri') required this.tokenUri,
      required this.total,
      @JsonKey(name: 'total_string') required this.totalString,
      required final List<NFTAttributes>? traits})
      : _floorPrices = floorPrices,
        _traits = traits;

  factory _$NFTImpl.fromJson(Map<String, dynamic> json) =>
      _$$NFTImplFromJson(json);

  @override
  @JsonKey(name: 'contract_address')
  final String contractAddress;
  @override
  @JsonKey(name: 'erc_type')
  final String? ercType;
  final List<NFTFloorPrice>? _floorPrices;
  @override
  @JsonKey(name: 'floor_prices')
  List<NFTFloorPrice>? get floorPrices {
    final value = _floorPrices;
    if (value == null) return null;
    if (_floorPrices is EqualUnmodifiableListView) return _floorPrices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'image_uri')
  final String? imageUri;
  @override
  final NFTMetadata? metadata;
  @override
  @JsonKey(name: 'mint_time')
  final DateTime mintTime;
  @override
  @JsonKey(name: 'mint_transaction_hash')
  final String mintTransactionHash;
  @override
  final String? name;
  @override
  final String? owner;
  @override
  @JsonKey(name: 'rarity_rank')
  final num? rarityRank;
  @override
  @JsonKey(name: 'rarity_score')
  final num? rarityScore;
  @override
  final String symbol;
  @override
  @JsonKey(name: 'token_id')
  final String tokenId;
  @override
  @JsonKey(name: 'token_uri')
  final String? tokenUri;
  @override
  final num? total;
  @override
  @JsonKey(name: 'total_string')
  final String? totalString;
  final List<NFTAttributes>? _traits;
  @override
  List<NFTAttributes>? get traits {
    final value = _traits;
    if (value == null) return null;
    if (_traits is EqualUnmodifiableListView) return _traits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'NFT(contractAddress: $contractAddress, ercType: $ercType, floorPrices: $floorPrices, imageUri: $imageUri, metadata: $metadata, mintTime: $mintTime, mintTransactionHash: $mintTransactionHash, name: $name, owner: $owner, rarityRank: $rarityRank, rarityScore: $rarityScore, symbol: $symbol, tokenId: $tokenId, tokenUri: $tokenUri, total: $total, totalString: $totalString, traits: $traits)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NFTImpl &&
            (identical(other.contractAddress, contractAddress) ||
                other.contractAddress == contractAddress) &&
            (identical(other.ercType, ercType) || other.ercType == ercType) &&
            const DeepCollectionEquality()
                .equals(other._floorPrices, _floorPrices) &&
            (identical(other.imageUri, imageUri) ||
                other.imageUri == imageUri) &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata) &&
            (identical(other.mintTime, mintTime) ||
                other.mintTime == mintTime) &&
            (identical(other.mintTransactionHash, mintTransactionHash) ||
                other.mintTransactionHash == mintTransactionHash) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.owner, owner) || other.owner == owner) &&
            (identical(other.rarityRank, rarityRank) ||
                other.rarityRank == rarityRank) &&
            (identical(other.rarityScore, rarityScore) ||
                other.rarityScore == rarityScore) &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.tokenId, tokenId) || other.tokenId == tokenId) &&
            (identical(other.tokenUri, tokenUri) ||
                other.tokenUri == tokenUri) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.totalString, totalString) ||
                other.totalString == totalString) &&
            const DeepCollectionEquality().equals(other._traits, _traits));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      contractAddress,
      ercType,
      const DeepCollectionEquality().hash(_floorPrices),
      imageUri,
      metadata,
      mintTime,
      mintTransactionHash,
      name,
      owner,
      rarityRank,
      rarityScore,
      symbol,
      tokenId,
      tokenUri,
      total,
      totalString,
      const DeepCollectionEquality().hash(_traits));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NFTImplCopyWith<_$NFTImpl> get copyWith =>
      __$$NFTImplCopyWithImpl<_$NFTImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NFTImplToJson(
      this,
    );
  }
}

abstract class _NFT implements NFT {
  const factory _NFT(
      {@JsonKey(name: 'contract_address') required final String contractAddress,
      @JsonKey(name: 'erc_type') required final String? ercType,
      @JsonKey(name: 'floor_prices')
      required final List<NFTFloorPrice>? floorPrices,
      @JsonKey(name: 'image_uri') required final String? imageUri,
      required final NFTMetadata? metadata,
      @JsonKey(name: 'mint_time') required final DateTime mintTime,
      @JsonKey(name: 'mint_transaction_hash')
      required final String mintTransactionHash,
      required final String? name,
      required final String? owner,
      @JsonKey(name: 'rarity_rank') required final num? rarityRank,
      @JsonKey(name: 'rarity_score') required final num? rarityScore,
      required final String symbol,
      @JsonKey(name: 'token_id') required final String tokenId,
      @JsonKey(name: 'token_uri') required final String? tokenUri,
      required final num? total,
      @JsonKey(name: 'total_string') required final String? totalString,
      required final List<NFTAttributes>? traits}) = _$NFTImpl;

  factory _NFT.fromJson(Map<String, dynamic> json) = _$NFTImpl.fromJson;

  @override
  @JsonKey(name: 'contract_address')
  String get contractAddress;
  @override
  @JsonKey(name: 'erc_type')
  String? get ercType;
  @override
  @JsonKey(name: 'floor_prices')
  List<NFTFloorPrice>? get floorPrices;
  @override
  @JsonKey(name: 'image_uri')
  String? get imageUri;
  @override
  NFTMetadata? get metadata;
  @override
  @JsonKey(name: 'mint_time')
  DateTime get mintTime;
  @override
  @JsonKey(name: 'mint_transaction_hash')
  String get mintTransactionHash;
  @override
  String? get name;
  @override
  String? get owner;
  @override
  @JsonKey(name: 'rarity_rank')
  num? get rarityRank;
  @override
  @JsonKey(name: 'rarity_score')
  num? get rarityScore;
  @override
  String get symbol;
  @override
  @JsonKey(name: 'token_id')
  String get tokenId;
  @override
  @JsonKey(name: 'token_uri')
  String? get tokenUri;
  @override
  num? get total;
  @override
  @JsonKey(name: 'total_string')
  String? get totalString;
  @override
  List<NFTAttributes>? get traits;
  @override
  @JsonKey(ignore: true)
  _$$NFTImplCopyWith<_$NFTImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
