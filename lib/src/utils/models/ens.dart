import 'package:freezed_annotation/freezed_annotation.dart';

part 'ens.freezed.dart';
part 'ens.g.dart';

@freezed
class ENS with _$ENS {
  const factory ENS({
    required String name,
    required String address,
    required String registrant,
    required String owner,
    required String resolver,
    @JsonKey(name: 'registrant_time') required DateTime registrantTime,
    @JsonKey(name: 'expiration_time') required DateTime expirationTime,
    @JsonKey(name: 'token_id') required String tokenId,
    @JsonKey(name: 'text_records') required dynamic textRecords,
  }) = _ENS;

  factory ENS.fromJson(Map<String, dynamic> json) => _$ENSFromJson(json);
}
