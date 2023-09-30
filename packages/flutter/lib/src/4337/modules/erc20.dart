import 'dart:convert';

import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/4337/modules/contract.dart';
import 'package:pks_4337_sdk/src/abi/abis.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

/// uses alchemy token api
/// if want to use another api, you have to create a custom class
class ERC20 {
  final BaseProvider _provider;

  ERC20(this._provider);

  String encodeERC20ApproveCall(
    EthereumAddress address,
    EthereumAddress spender,
    EtherAmount amount,
  ) {
    return bytesToHex(
        Contract.encodeFunctionCall(
          'approve',
          address,
          ContractAbis.get('ERC20'),
          [address.hex, spender.hex, amount.getInWei],
        ),
        include0x: true,
        padToEvenLength: true);
  }

  String encodeERC20TransferCall(
    EthereumAddress address,
    EthereumAddress recipient,
    EtherAmount amount,
  ) {
    return bytesToHex(
        Contract.encodeFunctionCall(
          'transfer',
          address,
          ContractAbis.get('ERC20'),
          [address.hex, recipient.hex, amount.getInWei],
        ),
        include0x: true,
        padToEvenLength: true);
  }

  Future<List<ERC20>> getBalances(EthereumAddress address,
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
        "Get ERC20 Balance: Malformed response, try again");

    return balances['tokenBalances']
        .map((e) => Token(EthereumAddress.fromHex(e['contractAddress']),
            EtherAmount.inWei(BigInt.parse(e['tokenBalance'])), null))
        .toList();
  }

  Future<BigInt> getTokenAllowance(
      EthereumAddress address, EthereumAddress owner, EthereumAddress spender) {
    Map<String, dynamic> params = {
      'contractAddress': address.hex,
      'owner': owner.hex,
      'spender': spender.hex
    };
    return _provider
        .send<String>('alchemy_getTokenAllowance', [params]).then(BigInt.parse);
  }

  Future<TokenMetadata> getTokenMetadata(EthereumAddress address,
      {bool save = true}) {
    return _provider.send<Map<String, dynamic>>(
        'alchemy_getTokenMetadata', [address.hex]).then((erc20Metadata) {
      return TokenMetadata.fromMap(erc20Metadata);
    });
  }
}

class Token {
  final EthereumAddress address;
  final EtherAmount balance;
  final TokenMetadata? metadata;

  Token(this.address, this.balance, this.metadata);

  factory Token.fromJson(String source) =>
      Token.fromMap(json.decode(source) as Map<String, dynamic>);

  factory Token.fromMap(Map<String, dynamic> map) {
    return Token(
        EthereumAddress.fromHex(map['address']),
        EtherAmount.inWei(map['balance'] as BigInt),
        map['metadata'] == null
            ? null
            : TokenMetadata.fromMap(map['metadata']));
  }

  Uint256 get toUint256 => Uint256.fromWei(balance);

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'address': address,
      'balance': balance.getInWei,
      'metadata': metadata?.toMap()
    };
  }
}

class TokenMetadata {
  int decimals;
  String logo;
  String name;
  String symbol;

  TokenMetadata({
    required this.decimals,
    required this.logo,
    required this.name,
    required this.symbol,
  });

  factory TokenMetadata.fromJson(String source) =>
      TokenMetadata.fromMap(json.decode(source) as Map<String, dynamic>);

  factory TokenMetadata.fromMap(Map<String, dynamic> map) {
    return TokenMetadata(
      decimals: map['decimals'] as int,
      logo: map['logo'] as String,
      name: map['name'] as String,
      symbol: map['symbol'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'decimals': decimals,
      'logo': logo,
      'name': name,
      'symbol': symbol,
    };
  }
}
