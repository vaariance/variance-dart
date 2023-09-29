
import 'dart:convert';

import 'package:pks_4337_sdk/pks_4337_sdk.dart';

enum TransferCategory { external, internal, erc721, erc1155, erc20, specialnft }

class TransferResponse {
  final List<Transfer> transfers;
  final String? pageKey;
  final ResponseType responseType;

  TransferResponse({
    required this.transfers,
    this.pageKey,
    required this.responseType,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'transfers': transfers.map((x) => x.toMap()).toList(),
      'pageKey': pageKey,
      'responseType': responseType.name,
    };
  }

  factory TransferResponse.fromMap(
      Map<String, dynamic> map, ResponseType responseType) {
    return TransferResponse(
      transfers: List<Transfer>.from(
        (map['transfers'] as List<Map<String, dynamic>>).map<Transfer>(
          (x) => Transfer.fromMap(x, responseType),
        ),
      ),
      pageKey: map['pageKey'] != null ? map['pageKey'] as String : null,
      responseType: responseType,
    );
  }

  String toJson() => json.encode(toMap());

  factory TransferResponse.fromJson(String source, ResponseType responseType) =>
      TransferResponse.fromMap(
          json.decode(source) as Map<String, dynamic>, responseType);
}

class Transfer {
  Uint256 blockNum;
  String uniqueId;
  String hash;
  String from;
  String to;
  double? value;
  Uint256? erc721TokenId;
  Erc1155Metadata? erc1155Metadata;
  Uint256? tokenId;
  String? asset;
  TransferCategory category;
  RawContract rawContract;
  // optional
  TransferMetadata? metadata;

  Transfer({
    required this.blockNum,
    required this.uniqueId,
    required this.hash,
    required this.from,
    required this.to,
    this.value,
    this.erc721TokenId,
    this.erc1155Metadata,
    this.tokenId,
    this.asset,
    required this.category,
    required this.rawContract,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'blockNum': blockNum.toHex(),
      'uniqueId': uniqueId,
      'hash': hash,
      'from': from,
      'to': to,
      'value': value,
      'erc721TokenId': erc721TokenId?.toHex(),
      'erc1155Metadata': erc1155Metadata?.toMap(),
      'tokenId': tokenId?.toHex(),
      'asset': asset,
      'category': category,
      'rawContract': rawContract.toMap(),
      'metadata': {
        'blockTimestamp': metadata?.blockTimestamp,
      },
    };
  }

  factory Transfer.fromMap(
      Map<String, dynamic> map, ResponseType responseType) {
    return Transfer(
      blockNum: Uint256.fromHex(map['blockNum']),
      uniqueId: map['uniqueId'] as String,
      hash: map['hash'] as String,
      from: map['from'] as String,
      to: map['to'] as String,
      value: map['value'] != null ? map['value'] as double : null,
      erc721TokenId: map['erc721TokenId'] != null
          ? Uint256.fromHex(map['erc721TokenId'])
          : null,
      erc1155Metadata: map['erc1155Metadata'] != null
          ? Erc1155Metadata.fromMap(
              map['erc1155Metadata'] as Map<String, dynamic>)
          : null,
      tokenId: map['tokenId'] != null ? Uint256.fromHex(map['tokenId']) : null,
      asset: map['asset'] != null ? map['asset'] as String : null,
      category: TransferCategory.values.byName(map['category'] as String),
      rawContract:
          RawContract.fromMap(map['rawContract'] as Map<String, dynamic>),
      metadata: responseType == ResponseType.withMetadata
          ? TransferMetadata(
              blockTimestamp:
                  DateTime.parse(map['metadata']['blockTimestamp'] as String))
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Transfer.fromJson(String source, ResponseType responseType) =>
      Transfer.fromMap(
          json.decode(source) as Map<String, dynamic>, responseType);
}

class Erc1155Metadata {
  Uint256 tokenId;
  Uint256 value;

  Erc1155Metadata({
    required this.tokenId,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tokenId': tokenId.toHex(),
      'value': value.toHex(),
    };
  }

  factory Erc1155Metadata.fromMap(Map<String, dynamic> map) {
    return Erc1155Metadata(
      tokenId: Uint256.fromHex(map['tokenId']),
      value: Uint256.fromHex(map['value']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Erc1155Metadata.fromJson(String source) =>
      Erc1155Metadata.fromMap(json.decode(source) as Map<String, dynamic>);
}

class TransferMetadata {
  DateTime blockTimestamp;

  TransferMetadata({
    required this.blockTimestamp,
  });
}

class RawContract {
  Uint256? value;
  String? address;
  Uint256? decimal;

  RawContract({
    this.value,
    this.address,
    this.decimal,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'value': value?.toHex(),
      'address': address,
      'decimal': decimal?.toHex(),
    };
  }

  factory RawContract.fromMap(Map<String, dynamic> map) {
    return RawContract(
      value: map['value'] != null ? Uint256.fromHex(map['value']) : null,
      address: map['address'] != null ? map['address'] as String : null,
      decimal: map['decimal'] != null ? Uint256.fromHex(map['decimal']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory RawContract.fromJson(String source) =>
      RawContract.fromMap(json.decode(source) as Map<String, dynamic>);
}
