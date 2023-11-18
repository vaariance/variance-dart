import 'package:freezed_annotation/freezed_annotation.dart';

part 'token.freezed.dart';
part 'token.g.dart';

@freezed
class Token with _$Token {
  const factory Token(
      {required String balance,
      @JsonKey(name: 'contract_address') required String contractAddress,
      @JsonKey(name: 'current_usd_price') required num? currentUsdPrice,
      required num decimals,
      required List<TokenLogo>? logos,
      required String name,
      required String symbol,
      @JsonKey(name: 'total_supply') required String? totalSupply,
      required List<TokenUrl>? urls}) = _Token;

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
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
