
import 'dart:convert';

import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:web3dart/web3dart.dart';

class Erc20Balance {
  String address;
  EtherAmount balance;
  Erc20Balance(this.address, this.balance);

  Uint256 toUint256() {
    return Uint256.fromWei(balance);
  }

  static List<Erc20Balance> fromTokenMap(List<Map<String, dynamic>> list) {
    return list
        .map((e) => Erc20Balance(e['contractAddress'],
            EtherAmount.inWei(BigInt.parse(e['tokenBalance']))))
        .toList();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'address': address,
      'balance': balance.getInWei,
    };
  }

  factory Erc20Balance.fromMap(Map<String, dynamic> map) {
    return Erc20Balance(
      map['address'] as String,
      EtherAmount.inWei(map['balance'] as BigInt),
    );
  }

  String toJson() => json.encode(toMap());

  factory Erc20Balance.fromJson(String source) =>
      Erc20Balance.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Erc20TokenMetadata {
  int decimals;
  String logo;
  String name;
  String symbol;

  Erc20TokenMetadata({
    required this.decimals,
    required this.logo,
    required this.name,
    required this.symbol,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'decimals': decimals,
      'logo': logo,
      'name': name,
      'symbol': symbol,
    };
  }

  factory Erc20TokenMetadata.fromMap(Map<String, dynamic> map) {
    return Erc20TokenMetadata(
      decimals: map['decimals'] as int,
      logo: map['logo'] as String,
      name: map['name'] as String,
      symbol: map['symbol'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Erc20TokenMetadata.fromJson(String source) =>
      Erc20TokenMetadata.fromMap(json.decode(source) as Map<String, dynamic>);
}
