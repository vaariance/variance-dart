import 'dart:convert';
import 'dart:typed_data';

import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/4337/modules/contract.dart';
import 'package:pks_4337_sdk/src/4337/wallet.dart' as sdk;
import 'package:pks_4337_sdk/src/abi/abis.dart';
import 'package:web3dart/web3dart.dart';

/// [ERC20] module
///
/// uses alchemy token api to get token balances
/// If you want to use another api, you have to create a custom class
class ERC20 {
  final BaseProvider _provider;

  ERC20(this._provider);

  /// [getBalances] returns the balance of all ERC20 tokens in an address
  /// metadata is not included in this fetch
  /// - @param  [address] is the address to get the balance of
  /// - @param optional [allowedContracts] is the list of allowed contracts
  /// - @param optional [pageKey] is the page key for pagination
  /// - @param optional [maxCount] is the maximum number of tokens to return
  Future<List<Token>> getBalances(EthereumAddress address,
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

    if (balances['address'] != address.hex) {
      throw Exception("Get ERC20 Balance: Malformed response, try again");
    }

    List<Token> erc20List = balances['tokenBalances']
        .map<Token>((e) => Token(EthereumAddress.fromHex(e['contractAddress']),
            EtherAmount.inWei(BigInt.parse(e['tokenBalance'])), null))
        .toList();
    return erc20List;
  }

  /// [getTokenAllowance] returns the ERC20 token allowance of an address
  /// - @param [contractAddress] is the address of the contract
  /// - @param [owner] is the address of the owner
  /// - @param [spender] is the address of the spender
  /// returns the allowance in [BigInt]
  Future<BigInt> getTokenAllowance(EthereumAddress contractAddress,
      EthereumAddress owner, EthereumAddress spender) {
    Map<String, dynamic> params = {
      'contract': contractAddress.hex,
      'owner': owner.hex,
      'spender': spender.hex
    };
    return _provider
        .send<String>('alchemy_getTokenAllowance', [params]).then(BigInt.parse);
  }

  /// [getTokenMetadata] returns the metadata for an ERC20 Token
  /// - @param [address] is the address of the token
  /// - @param optional [save] if you want to cache the fetched metadata in memory
  Future<TokenMetadata> getTokenMetadata(EthereumAddress address,
      {bool save = true}) {
    return _provider.send<Map<String, dynamic>>(
        'alchemy_getTokenMetadata', [address.hex]).then((erc20Metadata) {
      return TokenMetadata.fromMap(erc20Metadata);
    });
  }

  /// [encodeERC20ApproveCall] returns the calldata for ERC20 approval
  /// - @param [address] is the 4337 wallet address
  /// - @param [spender] is the address of the approved spender
  /// - @param [amount] is the amount to approve for the spender
  static Uint8List encodeERC20ApproveCall(
    EthereumAddress address,
    EthereumAddress spender,
    EtherAmount amount,
  ) {
    return Contract.encodeFunctionCall(
      'approve',
      address,
      ContractAbis.get('ERC20'),
      [spender, amount.getInWei],
    );
  }

  /// [encodeERC20TransferCall] returns the calldata for ERC20 transfer
  /// - @param [address] is the 4337 wallet address
  /// - @param [recipient] is the address of the recipient
  /// - @param [amount] is the amount to transfer
  static Uint8List encodeERC20TransferCall(
    EthereumAddress address,
    EthereumAddress recipient,
    EtherAmount amount,
  ) {
    return Contract.encodeFunctionCall(
      'transfer',
      address,
      ContractAbis.get('ERC20'),
      [recipient, amount.getInWei],
    );
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

  /// [approveToken] returns the userOperation for an ERC20 approval
  /// - @param [owner] is the 4337 wallet address
  /// - @param [spender] is the address of the approved spender
  /// - @param [amount] is the amount to approve for the spender
  /// returns the userOperation
  UserOperation approveToken(
    EthereumAddress owner,
    EthereumAddress spender,
    EtherAmount amount,
  ) {
    final callData = sdk.Wallet.execute(owner,
        to: address,
        innerCallData: ERC20.encodeERC20ApproveCall(address, spender, amount));
    return UserOperation.partial(hexlify(callData));
  }

  /// [transferToken] returns the userOperation for an ERC20 transfer
  /// - @param [owner] is the 4337 wallet address
  /// - @param [recipient] is the address of the recipient
  /// - @param [amount] is the amount to transfer
  /// returns the userOperation
  UserOperation transferToken(
      EthereumAddress owner, EthereumAddress recipient, EtherAmount amount) {
    final callData = sdk.Wallet.execute(owner,
        to: address,
        innerCallData:
            ERC20.encodeERC20TransferCall(address, recipient, amount));
    return UserOperation.partial(hexlify(callData));
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'address': address,
      'balance': balance.getInWei,
      'metadata': metadata?.toMap()
    };
  }
}

/// [TokenMetadata] is the metadata for an ERC20 Token
///
/// - [decimals] is the number of decimals
/// - [logo] is the logo url
/// - [name] is the name of the token
/// - [symbol] is the symbol of the token
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
