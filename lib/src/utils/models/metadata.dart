import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:variance_dart/utils.dart'
    show BigIntConverter, TokenLogo, TokenUrl;
import 'package:variance_dart/variance.dart' show Uint256;

part 'metadata.freezed.dart';
part 'metadata.g.dart';

@freezed
class TokenMetadata with _$TokenMetadata {
  const factory TokenMetadata({
    @JsonKey(name: 'contract_address') required String contractAddress,
    required num decimals,
    required String name,
    required String symbol,
    @BigIntConverter()
    @JsonKey(name: 'total_supply')
    required Uint256 totalSupply,
    required List<TokenLogo>? logos,
    required List<TokenUrl>? urls,
    @JsonKey(name: 'current_usd_price') required num? currentUsdPrice,
  }) = _TokenMetadata;

  factory TokenMetadata.fromJson(Map<String, dynamic> json) =>
      _$TokenMetadataFromJson(json);
}
