import 'dart:convert';

import 'package:pks_4337_sdk/src/common/uint256.dart';

class ERC1155Metadata {
  final Uint256 tokenId;
  final Uint256 value;

  ERC1155Metadata(
    this.tokenId,
    this.value,
  );

  factory ERC1155Metadata.fromJson(String source) =>
      ERC1155Metadata.fromMap(json.decode(source) as Map<String, dynamic>);

  factory ERC1155Metadata.fromMap(Map<String, dynamic> map) {
    return ERC1155Metadata(
      Uint256.fromHex(map['tokenId']),
      Uint256.fromHex(map['value']),
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tokenId': tokenId.toHex(),
      'value': value.toHex(),
    };
  }
}
