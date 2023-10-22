// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:pks_4337_sdk/src/modules/covalent_api/covalent_api.dart';
import 'package:web3dart/web3dart.dart';

class CovalentTransactionsApi extends BaseCovalentApi {
  CovalentTransactionsApi(
    super._apiKey,
    super.chainName,
  );

  Future<TransactionRecord> getTokenTransfersByContract(
    EthereumAddress walletAddress, {
    QuoteCurrency quoteCurrency = QuoteCurrency.USD,
    required EthereumAddress contractAddress,
    int? fromBlock,
    int? toBlock,
    int? pageSize,
    int? pageNumber,
  }) async {
    final response = await fetchApiRequest(
        baseCovalentApiUri
            .resolve('address/${walletAddress.hex}/transfers_v2/')
            .path,
        {
          'quote-currency': quoteCurrency.name,
          'contract-address': contractAddress.hex,
          if (fromBlock != null) 'starting-block': fromBlock,
          if (toBlock != null) 'ending-block': toBlock,
          if (pageSize != null) 'page-size': pageSize,
          if (pageNumber != null) 'page-number': pageNumber,
        });
    return TransactionRecord.fromMap(response['data']);
  }

  Future<Transaction> getTransactionByHash(
    String txHash, {
    QuoteCurrency quoteCurrency = QuoteCurrency.USD,
    bool omitLogs = false,
    bool withDexTrades = false,
    bool withNftSales = false,
    bool withLending = false,
    bool withSafe = false,
  }) async {
    final response = await fetchApiRequest(
        baseCovalentApiUri
            .resolve('transaction_v2/${txHash.toLowerCase()}/')
            .path,
        {
          'quote-currency': quoteCurrency.name,
          if (omitLogs) 'no-logs': omitLogs,
          if (withDexTrades) 'with-dex': withDexTrades,
          if (withNftSales) 'with-nft-sales': withNftSales,
          if (withLending) 'with-lending': withLending,
          if (withSafe) 'with-safe': withSafe,
        });

    return Transaction.fromMap((response['data']['items'] as List).first);
  }

  Future<List<Transaction>> getTransactionsForAddress(
    EthereumAddress walletAddress, {
    QuoteCurrency quoteCurrency = QuoteCurrency.USD,
    bool omitLogs = false,
    bool orderByAsc = false,
    bool withSafe = false,
  }) async {
    final response = await fetchApiRequest(
        baseCovalentApiUri
            .resolve('address/${walletAddress.hex}/transactions_v3/')
            .path,
        {
          'quote-currency': quoteCurrency.name,
          if (omitLogs) 'no-logs': omitLogs,
          if (orderByAsc) 'block-signed-at-asc': orderByAsc,
          if (withSafe) 'with-safe': withSafe,
        });
    return List<Transaction>.from(
      (response['data']['items']).map<Transaction>(
        (x) => Transaction.fromMap(x),
      ),
    );
  }
}

class GasMetadata {
  final num? contractDecimals;
  final String? contractName;
  final String? contractTickerSymbol;
  final EthereumAddress? contractAddress;
  final List<String>? supportsErc;
  final String? logoUrl;

  GasMetadata({
    required this.contractDecimals,
    required this.contractName,
    required this.contractTickerSymbol,
    required this.contractAddress,
    this.supportsErc,
    required this.logoUrl,
  });

  factory GasMetadata.fromJson(String source) =>
      GasMetadata.fromMap(json.decode(source) as Map<String, dynamic>);

  factory GasMetadata.fromMap(Map<String, dynamic> map) {
    return GasMetadata(
      contractDecimals: map['contract_decimals'],
      contractName: map['contract_name'],
      contractTickerSymbol: map['contract_ticker_symbol'],
      contractAddress: EthereumAddress.fromHex(map['contract_address']),
      supportsErc: map['supports_erc'] != null
          ? List<String>.from((map['supports_erc'] as List<String>))
          : null,
      logoUrl: map['logo_url'],
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
    };
  }
}

class Pagination {
  final bool? hasMore;
  final int? pageNumber;
  final int? pageSize;
  final int? totalCount;

  Pagination({
    required this.hasMore,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
  });

  factory Pagination.fromJson(String source) =>
      Pagination.fromMap(json.decode(source) as Map<String, dynamic>);

  factory Pagination.fromMap(Map<String, dynamic> map) {
    return Pagination(
      hasMore: map['has_more'],
      pageNumber: map['page_number'],
      pageSize: map['page_size'],
      totalCount: map['total_count'],
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'has_more': hasMore,
      'page_number': pageNumber,
      'page_size': pageSize,
      'total_count': totalCount,
    };
  }
}

class Transaction {
  final DateTime? blockSignedAt;
  final int? blockHeight;
  final String? blockHash;
  final String? txHash;
  final int? txOffset;
  final bool? successful;
  final EthereumAddress? minerAddress;
  final EthereumAddress? fromAddress;
  final String? fromAddressLabel;
  final EthereumAddress? toAddress;
  final String? toAddressLabel;
  final String? value;
  final double? valueQuote;
  final String? prettyValueQuote;
  final GasMetadata? gasMetadata;
  final BigInt? gasOffered;
  final BigInt? gasSpent;
  final EtherAmount? gasPrice;
  final EtherAmount? feesPaid;
  final double? gasQuote;
  final String? prettyGasQuote;
  final double? gasQuoteRate;
  final List<Transfer>? transfers;
  final List<Map<String, dynamic>>? logs;

  Transaction(
      {required this.blockSignedAt,
      required this.blockHeight,
      required this.blockHash,
      required this.txHash,
      required this.txOffset,
      required this.successful,
      required this.minerAddress,
      required this.fromAddress,
      required this.fromAddressLabel,
      required this.toAddress,
      required this.toAddressLabel,
      required this.value,
      required this.valueQuote,
      required this.prettyValueQuote,
      required this.gasMetadata,
      required this.gasOffered,
      required this.gasSpent,
      required this.gasPrice,
      required this.feesPaid,
      required this.gasQuote,
      required this.prettyGasQuote,
      required this.gasQuoteRate,
      this.transfers,
      this.logs});

  factory Transaction.fromJson(String source) =>
      Transaction.fromMap(json.decode(source) as Map<String, dynamic>);

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
        blockSignedAt: DateTime.parse(map['block_signed_at']),
        blockHeight: map['block_height'],
        blockHash: map['block_hash'],
        txHash: map['tx_hash'],
        txOffset: map['tx_offset'],
        successful: map['successful'],
        minerAddress: map['miner_address'] != null
            ? EthereumAddress.fromHex(map['miner_address'])
            : null,
        fromAddress: EthereumAddress.fromHex(map['from_address']),
        fromAddressLabel: map['from_address_label'],
        toAddress: EthereumAddress.fromHex(map['to_address']),
        toAddressLabel: map['to_address_label'],
        value: map['value'],
        valueQuote: map['value_quote'].toDouble(),
        prettyValueQuote: map['pretty_value_quote'],
        gasMetadata: map['gas_metadata'] != null
            ? GasMetadata.fromMap(map['gas_metadata'])
            : null,
        gasOffered: BigInt.from(map['gas_offered']),
        gasSpent: BigInt.from(map['gas_spent']),
        gasPrice: EtherAmount.fromInt(EtherUnit.wei, map['gas_price']),
        feesPaid: EtherAmount.fromBase10String(EtherUnit.wei, map['fees_paid']),
        gasQuote: map['gas_quote'],
        prettyGasQuote: map['pretty_gas_quote'],
        gasQuoteRate: map['gas_quote_rate'],
        transfers: map['transfers'] != null
            ? List<Transfer>.from(
                (map['transfers']).map<Transfer>(
                  (x) => Transfer.fromMap(x),
                ),
              )
            : null,
        logs: map['log_events'] != null
            ? List<Map<String, dynamic>>.from(map['log_events'])
            : null);
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'block_signed_at': blockSignedAt?.toIso8601String(),
      'block_height': blockHeight,
      'block_hash': blockHash,
      'tx_hash': txHash,
      'tx_offset': txOffset,
      'successful': successful,
      'miner_address': minerAddress?.hex,
      'from_address': fromAddress?.hex,
      'from_address_label': fromAddressLabel,
      'to_address': toAddress?.hex,
      'to_address_label': toAddressLabel,
      'value': value,
      'value_quote': valueQuote,
      'pretty_value_quote': prettyValueQuote,
      'gas_metadata': gasMetadata?.toMap(),
      'gas_offered': gasOffered.toString(),
      'gas_spent': gasSpent.toString(),
      'gas_price': gasPrice?.getInWei.toString(),
      'fees_paid': feesPaid?.getInWei.toString(),
      'gas_quote': gasQuote,
      'pretty_gas_quote': prettyGasQuote,
      'gas_quote_rate': gasQuoteRate,
      'transfers': transfers?.map((x) => x.toMap()).toList(),
      'log_events': logs,
    };
  }
}

class TransactionRecord {
  final Pagination? pagination;
  final List<Transaction>? transaction;

  TransactionRecord({
    required this.pagination,
    required this.transaction,
  });

  factory TransactionRecord.fromJson(String source) =>
      TransactionRecord.fromMap(json.decode(source) as Map<String, dynamic>);

  factory TransactionRecord.fromMap(Map<String, dynamic> map) {
    return TransactionRecord(
      pagination: Pagination.fromMap(map['pagination'] as Map<String, dynamic>),
      transaction: List<Transaction>.from(
        (map['items']).map<Transaction>(
          (x) => Transaction.fromMap(x),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pagination': pagination?.toMap(),
      'transaction': transaction?.map((x) => x.toMap()).toList(),
    };
  }
}

class Transfer {
  final DateTime? blockSignedAt;
  final String? txHash;
  final EthereumAddress? fromAddress;
  final String? fromAddressLabel;
  final EthereumAddress? toAddress;
  final String? toAddressLabel;
  final int? contractDecimals;
  final String? contractName;
  final String? contractTickerSymbol;
  final EthereumAddress? contractAddress;
  final String? logoUrl;
  final String? transferType;
  final BigInt? delta;
  final EtherAmount? balance;
  final double? quoteRate;
  final double? deltaQuote;
  final String? prettyDeltaQuote;
  final double? balanceQuote;
  final Object? methodCalls;

  Transfer({
    required this.blockSignedAt,
    required this.txHash,
    required this.fromAddress,
    required this.fromAddressLabel,
    required this.toAddress,
    required this.toAddressLabel,
    required this.contractDecimals,
    required this.contractName,
    required this.contractTickerSymbol,
    required this.contractAddress,
    required this.logoUrl,
    required this.transferType,
    required this.delta,
    required this.balance,
    required this.quoteRate,
    required this.deltaQuote,
    required this.prettyDeltaQuote,
    required this.balanceQuote,
    required this.methodCalls,
  });

  factory Transfer.fromJson(String source) =>
      Transfer.fromMap(json.decode(source) as Map<String, dynamic>);

  factory Transfer.fromMap(Map<String, dynamic> map) {
    return Transfer(
      blockSignedAt: DateTime.parse(map['block_signed_at']),
      txHash: map['tx_hash'],
      fromAddress: EthereumAddress.fromHex(map['from_address']),
      fromAddressLabel: map['from_address_label'],
      toAddress: EthereumAddress.fromHex(map['to_address']),
      toAddressLabel: map['to_address_label'],
      contractDecimals: map['contract_decimals'],
      contractName: map['contract_name'],
      contractTickerSymbol: map['contract_ticker_symbol'],
      contractAddress: EthereumAddress.fromHex(map['contract_address']),
      logoUrl: map['logo_url'],
      transferType: map['transfer_type'],
      delta: BigInt.parse(map['delta']),
      balance: map['balance'] != null
          ? EtherAmount.fromBase10String(EtherUnit.wei, map['balance'])
          : null,
      quoteRate: map['quote_rate'],
      deltaQuote: map['delta_quote'],
      prettyDeltaQuote: map['pretty_delta_quote'],
      balanceQuote: map['balance_quote'],
      methodCalls: map['method_calls'] != null
          ? map['method_calls'] as Map<String, dynamic>
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'block_signed_at': blockSignedAt?.toIso8601String(),
      'tx_hash': txHash,
      'from_address': fromAddress?.hex,
      'from_address_label': fromAddressLabel,
      'to_address': toAddress?.hex,
      'to_address_label': toAddressLabel,
      'contract_decimals': contractDecimals,
      'contract_name': contractName,
      'contract_ticker_symbol': contractTickerSymbol,
      'contract_address': contractAddress?.hex,
      'logo_url': logoUrl,
      'transfer_type': transferType,
      'delta': delta.toString(),
      'balance': balance?.getInWei.toString(),
      'quote_rate': quoteRate,
      'delta_quote': deltaQuote,
      'pretty_delta_quote': prettyDeltaQuote,
      'balance_quote': balanceQuote,
      'method_calls': methodCalls,
    };
  }
}
