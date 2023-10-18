// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:pks_4337_sdk/src/modules/covalent_api/covalent_api.dart';
import 'package:web3dart/web3dart.dart';

class CovalentTokenApi extends BaseCovalentApi {
  CovalentTokenApi(
    super._apiKey,
    super.chainName,
  );

  Future<List<Token>> getBalances(
    EthereumAddress walletAddress, {
    QuoteCurrency quoteCurrency = QuoteCurrency.USD,
    bool nft = false,
    bool noNftFetch = true,
    bool noSpam = false,
    bool noNftAssetMetadata = false,
  }) async {
    final response = await fetchApiRequest(
        baseCovalentApiUri
            .resolve('address/${walletAddress.hex}/balances_v2')
            .path,
        {
          'quote-currency': quoteCurrency.name,
          'nft': nft,
          'no-nft-fetch': noNftFetch,
          if (noSpam) 'no-spam': noSpam,
          if (noNftAssetMetadata) 'no-nft-asset-metadata': noNftAssetMetadata,
        });
    return List<Token>.from(
        (response['items'] as List).map((x) => Token.fromMap(x)));
  }

  Future<List<TokenApproval>> getTokenAllowance(
      EthereumAddress walletAddress) async {
    final response = await fetchApiRequest(
        baseCovalentApiUri.resolve('approvals/${walletAddress.hex}').path, {});
    return List<TokenApproval>.from(
        (response['items'] as List).map((x) => TokenApproval.fromMap(x)));
  }
}

class Token {
  final int contractDecimals;
  final String? contractName;
  final String? contractTickerSymbol;
  final EthereumAddress contractAddress;
  final List<String>? supportsErc;
  final String logoUrl;
  final DateTime lastTransferredAt;
  final bool nativeToken;
  final String type;
  final bool isSpam;
  final EtherAmount balance;
  final EtherAmount balance24H;
  final double? quoteRate;
  final double? quoteRate24H;
  final double? quote;
  final String? prettyQuote;
  final double? quote24H;
  final String? prettyQuote24H;
  final List<NFTData>? nftData;

  Token({
    required this.contractDecimals,
    required this.contractName,
    required this.contractTickerSymbol,
    required this.contractAddress,
    required this.supportsErc,
    required this.logoUrl,
    required this.lastTransferredAt,
    required this.nativeToken,
    required this.type,
    required this.isSpam,
    required this.balance,
    required this.balance24H,
    required this.quoteRate,
    required this.quoteRate24H,
    required this.quote,
    required this.prettyQuote,
    required this.quote24H,
    required this.prettyQuote24H,
    required this.nftData,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'contractDecimals': contractDecimals,
      'contractName': contractName,
      'contractTickerSymbol': contractTickerSymbol,
      'contractAddress': contractAddress.hex,
      'supportsErc': supportsErc,
      'logoUrl': logoUrl,
      'lastTransferredAt': lastTransferredAt.toIso8601String(),
      'nativeToken': nativeToken,
      'type': type,
      'isSpam': isSpam,
      'balance': balance.getInWei.toString(),
      'balance24H': balance24H.getInWei.toString(),
      'quoteRate': quoteRate,
      'quoteRate24H': quoteRate24H,
      'quote': quote,
      'prettyQuote': prettyQuote,
      'quote24H': quote24H,
      'prettyQuote24H': prettyQuote24H,
      'nftData': nftData?.map((x) => x.toMap()).toList(),
    };
  }

  factory Token.fromMap(Map<String, dynamic> map) {
    return Token(
      contractDecimals: map['contractDecimals'],
      contractName: map['contractName'],
      contractTickerSymbol: map['contractTickerSymbol'],
      contractAddress: EthereumAddress.fromHex(map['contractAddress']),
      supportsErc: map['supportsErc'] != null
          ? List<String>.from(map['supportsErc'])
          : null,
      logoUrl: map['logoUrl'],
      lastTransferredAt: DateTime.parse(map['lastTransferredAt']),
      nativeToken: map['nativeToken'],
      type: map['type'],
      isSpam: map['isSpam'],
      balance: EtherAmount.fromBase10String(EtherUnit.wei, map['balance']),
      balance24H:
          EtherAmount.fromBase10String(EtherUnit.wei, map['balance24H']),
      quoteRate: map['quoteRate'],
      quoteRate24H: map['quoteRate24H'],
      quote: map['quote'],
      prettyQuote: map['prettyQuote'],
      quote24H: map['quote24H'],
      prettyQuote24H: map['prettyQuote24H'],
      nftData: map['nftData'] != null
          ? List<NFTData>.from(
              (map['nftData']).map<NFTData?>(
                (x) => NFTData.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Token.fromJson(String source) =>
      Token.fromMap(json.decode(source) as Map<String, dynamic>);
}

enum QuoteCurrency {
  USD,
  CAD,
  EUR,
  SGD,
  INR,
  JPY,
  VND,
  CNY,
  KRW,
  RUB,
  TRY,
  NGN,
  ARS,
  AUD,
  CHF,
  GBP
}

class TokenApproval {
  final EthereumAddress tokenAddress;
  final String tokenAddressLabel;
  final String tickerSymbol;
  final int contractDecimals;
  final String logoUrl;
  final double quoteRate;
  final EtherAmount balance;
  final double balanceQuote;
  final String prettyBalanceQuote;
  final EtherAmount valueAtRisk;
  final double valueAtRiskQuote;
  final String prettyValueAtRiskQuote;
  final List<Spender> spenders;

  TokenApproval({
    required this.tokenAddress,
    required this.tokenAddressLabel,
    required this.tickerSymbol,
    required this.contractDecimals,
    required this.logoUrl,
    required this.quoteRate,
    required this.balance,
    required this.balanceQuote,
    required this.prettyBalanceQuote,
    required this.valueAtRisk,
    required this.valueAtRiskQuote,
    required this.prettyValueAtRiskQuote,
    required this.spenders,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tokenAddress': tokenAddress.hex,
      'tokenAddressLabel': tokenAddressLabel,
      'tickerSymbol': tickerSymbol,
      'contractDecimals': contractDecimals,
      'logoUrl': logoUrl,
      'quoteRate': quoteRate,
      'balance': balance.getInWei.toString(),
      'balanceQuote': balanceQuote,
      'prettyBalanceQuote': prettyBalanceQuote,
      'valueAtRisk': valueAtRisk.getInWei.toString(),
      'valueAtRiskQuote': valueAtRiskQuote,
      'prettyValueAtRiskQuote': prettyValueAtRiskQuote,
      'spenders': spenders.map((x) => x.toMap()).toList(),
    };
  }

  factory TokenApproval.fromMap(Map<String, dynamic> map) {
    return TokenApproval(
      tokenAddress: EthereumAddress.fromHex(map['tokenAddress']),
      tokenAddressLabel: map['tokenAddressLabel'],
      tickerSymbol: map['tickerSymbol'],
      contractDecimals: map['contractDecimals'],
      logoUrl: map['logoUrl'],
      quoteRate: map['quoteRate'],
      balance: EtherAmount.fromBase10String(EtherUnit.wei, map['balance']),
      balanceQuote: map['balanceQuote'],
      prettyBalanceQuote: map['prettyBalanceQuote'],
      valueAtRisk:
          EtherAmount.fromBase10String(EtherUnit.wei, map['valueAtRisk']),
      valueAtRiskQuote: map['valueAtRiskQuote'],
      prettyValueAtRiskQuote: map['prettyValueAtRiskQuote'],
      spenders: List<Spender>.from(
        (map['spenders']).map<Spender>(
          (x) => Spender.fromMap(x),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory TokenApproval.fromJson(String source) =>
      TokenApproval.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Spender {
  final int blockHeight;
  final int txOffset;
  final int logOffset;
  final DateTime blockSignedAt;
  final String txHash;
  final EthereumAddress spenderAddress;
  final String? spenderAddressLabel;
  final String allowance;
  final double? allowanceQuote;
  final String? prettyAllowanceQuote;
  final EtherAmount valueAtRisk;
  final double valueAtRiskQuote;
  final String prettyValueAtRiskQuote;
  final String riskFactor;

  Spender({
    required this.blockHeight,
    required this.txOffset,
    required this.logOffset,
    required this.blockSignedAt,
    required this.txHash,
    required this.spenderAddress,
    required this.spenderAddressLabel,
    required this.allowance,
    required this.allowanceQuote,
    required this.prettyAllowanceQuote,
    required this.valueAtRisk,
    required this.valueAtRiskQuote,
    required this.prettyValueAtRiskQuote,
    required this.riskFactor,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'blockHeight': blockHeight,
      'txOffset': txOffset,
      'logOffset': logOffset,
      'blockSignedAt': blockSignedAt.toIso8601String(),
      'txHash': txHash,
      'spenderAddress': spenderAddress.hex,
      'spenderAddressLabel': spenderAddressLabel,
      'allowance': allowance,
      'allowanceQuote': allowanceQuote,
      'prettyAllowanceQuote': prettyAllowanceQuote,
      'valueAtRisk': valueAtRisk.getInWei.toString(),
      'valueAtRiskQuote': valueAtRiskQuote,
      'prettyValueAtRiskQuote': prettyValueAtRiskQuote,
      'riskFactor': riskFactor,
    };
  }

  factory Spender.fromMap(Map<String, dynamic> map) {
    return Spender(
      blockHeight: map['blockHeight'],
      txOffset: map['txOffset'],
      logOffset: map['logOffset'],
      blockSignedAt: DateTime.parse(map['blockSignedAt']),
      txHash: map['txHash'],
      spenderAddress: EthereumAddress.fromHex(map['spenderAddress']),
      spenderAddressLabel: map['spenderAddressLabel'],
      allowance: map['allowance'] as String,
      allowanceQuote: map['allowanceQuote'],
      prettyAllowanceQuote: map['prettyAllowanceQuote'],
      valueAtRisk:
          EtherAmount.fromBase10String(EtherUnit.wei, map['valueAtRisk']),
      valueAtRiskQuote: map['valueAtRiskQuote'],
      prettyValueAtRiskQuote: map['prettyValueAtRiskQuote'],
      riskFactor: map['riskFactor'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Spender.fromJson(String source) =>
      Spender.fromMap(json.decode(source) as Map<String, dynamic>);
}
