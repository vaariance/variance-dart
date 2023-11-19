import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:variance_dart/variance.dart' show Uint256;

part 'token.freezed.dart';
part 'token.g.dart';

@freezed
class Token with _$Token {
  const factory Token(
      {@HexConverter() required Uint256 balance,
      @JsonKey(name: 'contract_address') required String contractAddress,
      @JsonKey(name: 'current_usd_price') required num? currentUsdPrice,
      required num decimals,
      required List<TokenLogo>? logos,
      required String name,
      required String symbol,
      @BigIntConverter()
      @JsonKey(name: 'total_supply')
      required Uint256? totalSupply,
      required List<TokenUrl>? urls}) = _Token;

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
}

class HexConverter implements JsonConverter<Uint256, String> {
  const HexConverter();

  @override
  Uint256 fromJson(String json) {
    return Uint256.fromHex(json);
  }

  @override
  String toJson(Uint256 balance) {
    return balance.toHex();
  }
}

class BigIntConverter implements JsonConverter<Uint256, dynamic> {
  const BigIntConverter();

  @override
  Uint256 fromJson(dynamic json) {
    if (json is String) {
      return Uint256(BigInt.parse(json));
    }
    return Uint256(BigInt.from(json));
  }

  @override
  BigInt toJson(Uint256 balance) {
    return balance.value;
  }
}

class TokenUrl {
  TokenUrl({
    required this.name,
    required this.url,
  });

  factory TokenUrl.fromJson(Map<String, dynamic> json) => TokenUrl(
        name: json['name'],
        url: json['url'],
      );

  final String name;
  final String url;

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
      };
}

class TokenLogo {
  TokenLogo({
    required this.height,
    required this.uri,
    required this.width,
  });

  factory TokenLogo.fromJson(Map<String, dynamic> json) => TokenLogo(
        height: json['height'],
        uri: json['uri'],
        width: json['width'],
      );

  final num height;
  final String uri;
  final num width;

  Map<String, dynamic> toJson() => {
        'height': height,
        'uri': uri,
        'width': width,
      };
}
