import 'package:freezed_annotation/freezed_annotation.dart';

part 'price.freezed.dart';
part 'price.g.dart';

@freezed
class TokenPrice with _$TokenPrice {
  const factory TokenPrice({
    required num? price,
    required String? symbol,
    required num? decimals,
    @JsonKey(name: 'updated_at') required DateTime? updatedAt,
  }) = _TokenPrice;

  factory TokenPrice.fromJson(Map<String, dynamic> json) =>
      _$TokenPriceFromJson(json);
}
