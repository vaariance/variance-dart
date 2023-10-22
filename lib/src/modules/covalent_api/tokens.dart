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
            .resolve('address/${walletAddress.hex}/balances_v2/')
            .path,
        {
          'quote-currency': quoteCurrency.name,
          'nft': nft.toString(),
          'no-nft-fetch': noNftFetch.toString(),
          if (noSpam) 'no-spam': noSpam.toString(),
          if (noNftAssetMetadata)
            'no-nft-asset-metadata': noNftAssetMetadata.toString(),
        });
    return List<Token>.from(
        (response['data']['items'] as List).map((x) => Token.fromMap(x)));
  }

  Future<List<TokenApproval>> getTokenAllowance(
      EthereumAddress walletAddress) async {
    final response = await fetchApiRequest(
        baseCovalentApiUri.resolve('approvals/${walletAddress.hex}/').path, {});
    return List<TokenApproval>.from((response['data']['items'] as List)
        .map((x) => TokenApproval.fromMap(x)));
  }
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

class Spender {
  final int? blockHeight;
  final int? txOffset;
  final int? logOffset;
  final DateTime? blockSignedAt;
  final String? txHash;
  final EthereumAddress? spenderAddress;
  final String? spenderAddressLabel;
  final String? allowance;
  final double? allowanceQuote;
  final String? prettyAllowanceQuote;
  final EtherAmount? valueAtRisk;
  final double? valueAtRiskQuote;
  final String? prettyValueAtRiskQuote;
  final String? riskFactor;

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

  factory Spender.fromJson(String source) =>
      Spender.fromMap(json.decode(source) as Map<String, dynamic>);

  factory Spender.fromMap(Map<String, dynamic> map) {
    return Spender(
      blockHeight: map['block_height'],
      txOffset: map['tx_offset'],
      logOffset: map['log_offset'],
      blockSignedAt: DateTime.parse(map['block_signed_at']),
      txHash: map['tx_hash'],
      spenderAddress: EthereumAddress.fromHex(map['spender_address']),
      spenderAddressLabel: map['spender_address_label'],
      allowance: map['allowance'] as String,
      allowanceQuote: map['allowance_quote'],
      prettyAllowanceQuote: map['pretty_allowance_quote'],
      valueAtRisk:
          EtherAmount.fromBase10String(EtherUnit.wei, map['value_at_risk']),
      valueAtRiskQuote: map['value_at_risk_quote'],
      prettyValueAtRiskQuote: map['pretty_value_at_risk_quote'],
      riskFactor: map['risk_factor'],
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'block_height': blockHeight,
      'tx_offset': txOffset,
      'log_offset': logOffset,
      'block_signed_at': blockSignedAt?.toIso8601String(),
      'tx_hash': txHash,
      'spender_address': spenderAddress?.hex,
      'spender_address_label': spenderAddressLabel,
      'allowance': allowance,
      'allowance_quote': allowanceQuote,
      'pretty_allowance_quote': prettyAllowanceQuote,
      'value_at_risk': valueAtRisk?.getInWei.toString(),
      'value_at_risk_quote': valueAtRiskQuote,
      'pretty_value_at_risk_quote': prettyValueAtRiskQuote,
      'risk_factor': riskFactor,
    };
  }
}

class Token {
  final int? contractDecimals;
  final String? contractName;
  final String? contractTickerSymbol;
  final EthereumAddress? contractAddress;
  final List<String>? supportsErc;
  final String? logoUrl;
  final DateTime? lastTransferredAt;
  final bool? nativeToken;
  final String? type;
  final bool? isSpam;
  final EtherAmount? balance;
  final EtherAmount? balance24H;
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

  factory Token.fromJson(String source) =>
      Token.fromMap(json.decode(source) as Map<String, dynamic>);

  factory Token.fromMap(Map<String, dynamic> map) {
    return Token(
      contractDecimals: map['contract_decimals'],
      contractName: map['contract_name'],
      contractTickerSymbol: map['contract_ticker_symbol'],
      contractAddress: EthereumAddress.fromHex(map['contract_address']),
      supportsErc: map['supports_erc'] != null
          ? List<String>.from(map['supports_erc'])
          : null,
      logoUrl: map['logo_url'],
      lastTransferredAt: DateTime.parse(map['last_transferred_at']),
      nativeToken: map['native_token'],
      type: map['type'],
      isSpam: map['is_spam'],
      balance: EtherAmount.fromBase10String(EtherUnit.wei, map['balance']),
      balance24H:
          EtherAmount.fromBase10String(EtherUnit.wei, map['balance_24h']),
      quoteRate: map['quote_rate'],
      quoteRate24H: map['quote_rate_24h'],
      quote: map['quote'],
      prettyQuote: map['pretty_quote'],
      quote24H: map['quote_24h'],
      prettyQuote24H: map['pretty_quote_24h'],
      nftData: map['nft_data'] != null
          ? List<NFTData>.from(
              (map['nft_data']).map<NFTData?>(
                (x) => NFTData.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'contract_decimals': contractDecimals,
      'contract_name': contractName,
      'contract_ticker_symbol': contractTickerSymbol,
      'contract_address': contractAddress?.hex,
      'supports_erc': supportsErc,
      'logo_url': logoUrl,
      'last_transferred_at': lastTransferredAt?.toIso8601String(),
      'native_token': nativeToken,
      'type': type,
      'is_spam': isSpam,
      'balance': balance?.getInWei.toString(),
      'balance_24h': balance24H?.getInWei.toString(),
      'quote_rate': quoteRate,
      'quote_rate_24h': quoteRate24H,
      'quote': quote,
      'pretty_quote': prettyQuote,
      'quote_24h': quote24H,
      'pretty_quote_24h': prettyQuote24H,
      'nft_data': nftData?.map((x) => x.toMap()).toList(),
    };
  }
}

class TokenApproval {
  final EthereumAddress? tokenAddress;
  final String? tokenAddressLabel;
  final String? tickerSymbol;
  final int? contractDecimals;
  final String logoUrl;
  final double? quoteRate;
  final EtherAmount? balance;
  final double? balanceQuote;
  final String? prettyBalanceQuote;
  final EtherAmount? valueAtRisk;
  final double? valueAtRiskQuote;
  final String? prettyValueAtRiskQuote;
  final List<Spender>? spenders;

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

  factory TokenApproval.fromJson(String source) =>
      TokenApproval.fromMap(json.decode(source) as Map<String, dynamic>);

  factory TokenApproval.fromMap(Map<String, dynamic> map) {
    return TokenApproval(
      tokenAddress: EthereumAddress.fromHex(map['token_address']),
      tokenAddressLabel: map['token_address_label'],
      tickerSymbol: map['ticker_symbol'],
      contractDecimals: map['contract_decimals'],
      logoUrl: map['logo_url'],
      quoteRate: map['quote_rate'],
      balance: EtherAmount.fromBase10String(EtherUnit.wei, map['balance']),
      balanceQuote: map['balance_quote'],
      prettyBalanceQuote: map['pretty_balance_quote'],
      valueAtRisk:
          EtherAmount.fromBase10String(EtherUnit.wei, map['value_at_risk']),
      valueAtRiskQuote: map['value_at_risk_quote'],
      prettyValueAtRiskQuote: map['pretty_value_at_risk_quote'],
      spenders: List<Spender>.from(
        (map['spenders']).map<Spender>(
          (x) => Spender.fromMap(x),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'token_address': tokenAddress?.hex,
      'token_address_label': tokenAddressLabel,
      'ticker_symbol': tickerSymbol,
      'contract_decimals': contractDecimals,
      'logo_url': logoUrl,
      'quote_rate': quoteRate,
      'balance': balance?.getInWei.toString(),
      'balance_quote': balanceQuote,
      'pretty_balance_quote': prettyBalanceQuote,
      'value_at_risk': valueAtRisk?.getInWei.toString(),
      'value_at_risk_quote': valueAtRiskQuote,
      'pretty_value_at_risk_quote': prettyValueAtRiskQuote,
      'spenders': spenders?.map((x) => x.toMap()).toList(),
    };
  }
}
