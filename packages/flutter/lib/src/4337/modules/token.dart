// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:typed_data';

import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/4337/modules/contract.dart';
import 'package:pks_4337_sdk/src/4337/modules/contract_abis.dart';
import 'package:web3dart/web3dart.dart';

/// uses alchemy token api
/// if want to use another api, you have to create a custom class
class Tokens {
  final BaseProvider _provider;

  Tokens(this._provider);

  Future<BigInt> getTokenAllowances(EthereumAddress contractAddress,
      EthereumAddress owner, EthereumAddress spender) {
    Map<String, dynamic> params = {
      'contractAddress': contractAddress.hex,
      'owner': owner.hex,
      'spender': spender.hex
    };
    return _provider
        .send<String>('alchemy_getTokenAllowance', [params]).then(BigInt.parse);
  }

  Future<List<Erc20Balance>> getTokenBalances(EthereumAddress address,
      {List<String>? allowedContracts, int? pageKey, int? maxCount}) async {
    Map<String, dynamic> params = {
      'pageKey': pageKey,
      'maxCount': maxCount ?? 100
    };
    List call = [
      address.hex,
      allowedContracts ?? 'erc20',
      pageKey != null ? params : {}
    ];
    final balances = await _provider.send<Map<String, dynamic>>(
        'alchemy_getTokenBalances', call);
    require(balances['address'] == address.hex,
        "Get Balance: Malformed response, try again");

    return Erc20Balance.fromTokenMap(balances['tokenBalances']);
  }

  Future<Erc20TokenMetadata> getTokenMetadata(EthereumAddress contractAddress) {
    return _provider.send<Map<String, dynamic>>('alchemy_getTokenMetadata',
        [contractAddress.hex]).then(Erc20TokenMetadata.fromMap);
  }

  Uint8List encodeERC20ApproveCall(
    EthereumAddress tokenAddress,
    EthereumAddress spender,
    EtherAmount amount,
  ) {
    return Contract.encodeFunctionCall(
      'approve',
      tokenAddress,
      ContractAbis.get('ERC20'),
      [tokenAddress.hex, spender.hex, amount.getInWei],
    );
  }

  Uint8List encodeERC20TransferCall(
    EthereumAddress tokenAddress,
    EthereumAddress recipient,
    EtherAmount amount,
  ) {
    return Contract.encodeFunctionCall(
      'transfer',
      tokenAddress,
      ContractAbis.get('ERC20'),
      [tokenAddress.hex, recipient.hex, amount.getInWei],
    );
  }
}

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
