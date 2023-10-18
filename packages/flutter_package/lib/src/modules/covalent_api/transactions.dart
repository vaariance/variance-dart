// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:pks_4337_sdk/src/modules/covalent_api/covalent_api.dart';
import 'package:web3dart/web3dart.dart';

class CovalentTransactionsApi extends BaseCovalentApi {
  CovalentTransactionsApi(
    super._apiKey,
    super.chainName,
  );

  Future<List<Transaction>> getTransactionsForAddress(
    EthereumAddress walletAddress, {
    QuoteCurrency quoteCurrency = QuoteCurrency.USD,
    bool omitLogs = false,
    bool orderByAsc = false,
    bool withSafe = false,
  }) async {
    final response = await fetchApiRequest(
        baseCovalentApiUri
            .resolve('address/${walletAddress.hex}/transactions_v3')
            .path,
        {
          'quote-currency': quoteCurrency.name,
          if (omitLogs) 'no-logs': omitLogs,
          if (orderByAsc) 'block-signed-at-asc': orderByAsc,
          if (withSafe) 'with-safe': withSafe,
        });
    return List<Transaction>.from(
      (response['items']).map<Transaction>(
        (x) => Transaction.fromMap(x),
      ),
    );
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
            .resolve('transaction_v2/${txHash.toLowerCase()}')
            .path,
        {
          'quote-currency': quoteCurrency.name,
          if (omitLogs) 'no-logs': omitLogs,
          if (withDexTrades) 'with-dex': withDexTrades,
          if (withNftSales) 'with-nft-sales': withNftSales,
          if (withLending) 'with-lending': withLending,
          if (withSafe) 'with-safe': withSafe,
        });

    return Transaction.fromMap((response['items'] as List).first);
  }

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
            .resolve('address/${walletAddress.hex}/transfers_v2')
            .path,
        {
          'quote-currency': quoteCurrency.name,
          'contract-address': contractAddress.hex,
          if (fromBlock != null) 'starting-block': fromBlock,
          if (toBlock != null) 'ending-block': toBlock,
          if (pageSize != null) 'page-size': pageSize,
          if (pageNumber != null) 'page-number': pageNumber,
        });
    return TransactionRecord.fromMap(response);
  }
}

class TransactionRecord {
  final Pagination pagination;
  final List<Transaction> transaction;

  TransactionRecord({
    required this.pagination,
    required this.transaction,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pagination': pagination.toMap(),
      'transaction': transaction.map((x) => x.toMap()).toList(),
    };
  }

  factory TransactionRecord.fromMap(Map<String, dynamic> map) {
    return TransactionRecord(
      pagination: Pagination.fromMap(map['pagination'] as Map<String, dynamic>),
      transaction: List<Transaction>.from(
        (map['transaction']).map<Transaction>(
          (x) => Transaction.fromMap(x),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory TransactionRecord.fromJson(String source) =>
      TransactionRecord.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Pagination {
  final bool hasMore;
  final int pageNumber;
  final int pageSize;
  final int? totalCount;

  Pagination({
    required this.hasMore,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'hasMore': hasMore,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'totalCount': totalCount,
    };
  }

  factory Pagination.fromMap(Map<String, dynamic> map) {
    return Pagination(
      hasMore: map['hasMore'],
      pageNumber: map['pageNumber'],
      pageSize: map['pageSize'],
      totalCount: map['totalCount'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Pagination.fromJson(String source) =>
      Pagination.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Transaction {
  final DateTime blockSignedAt;
  final int blockHeight;
  final String? blockHash;
  final String txHash;
  final int txOffset;
  final bool successful;
  final EthereumAddress? minerAddress;
  final EthereumAddress fromAddress;
  final String? fromAddressLabel;
  final EthereumAddress toAddress;
  final String? toAddressLabel;
  final String value;
  final int valueQuote;
  final String prettyValueQuote;
  final GasMetadata? gasMetadata;
  final BigInt gasOffered;
  final BigInt gasSpent;
  final EtherAmount gasPrice;
  final EtherAmount feesPaid;
  final double gasQuote;
  final String prettyGasQuote;
  final double gasQuoteRate;
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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'blockSignedAt': blockSignedAt.toIso8601String(),
      'blockHeight': blockHeight,
      'blockHash': blockHash,
      'txHash': txHash,
      'txOffset': txOffset,
      'successful': successful,
      'minerAddress': minerAddress?.hex,
      'fromAddress': fromAddress.hex,
      'fromAddressLabel': fromAddressLabel,
      'toAddress': toAddress.hex,
      'toAddressLabel': toAddressLabel,
      'value': value,
      'valueQuote': valueQuote,
      'prettyValueQuote': prettyValueQuote,
      'gasMetadata': gasMetadata?.toMap(),
      'gasOffered': gasOffered.toString(),
      'gasSpent': gasSpent.toString(),
      'gasPrice': gasPrice.getInWei.toString(),
      'feesPaid': feesPaid.getInWei.toString(),
      'gasQuote': gasQuote,
      'prettyGasQuote': prettyGasQuote,
      'gasQuoteRate': gasQuoteRate,
      'transfers': transfers?.map((x) => x.toMap()).toList(),
      'logs': logs,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
        blockSignedAt: DateTime.parse(map['blockSignedAt']),
        blockHeight: map['blockHeight'],
        blockHash: map['blockHash'],
        txHash: map['txHash'],
        txOffset: map['txOffset'],
        successful: map['successful'],
        minerAddress: map['minerAddress'] != null
            ? EthereumAddress.fromHex(map['minerAddress'])
            : null,
        fromAddress: EthereumAddress.fromHex(map['fromAddress']),
        fromAddressLabel: map['fromAddressLabel'],
        toAddress: EthereumAddress.fromHex(map['toAddress']),
        toAddressLabel: map['toAddressLabel'],
        value: map['value'],
        valueQuote: map['valueQuote'],
        prettyValueQuote: map['prettyValueQuote'],
        gasMetadata: map['gasMetadata'] != null
            ? GasMetadata.fromMap(map['gasMetadata'])
            : null,
        gasOffered: BigInt.from(map['gasOffered']),
        gasSpent: BigInt.from(map['gasSpent']),
        gasPrice: EtherAmount.fromBigInt(EtherUnit.wei, map['gasPrice']),
        feesPaid: EtherAmount.fromBase10String(EtherUnit.wei, map['feesPaid']),
        gasQuote: map['gasQuote'],
        prettyGasQuote: map['prettyGasQuote'],
        gasQuoteRate: map['gasQuoteRate'],
        transfers: map['transfers'] != null
            ? List<Transfer>.from(
                (map['transfers']).map<Transfer>(
                  (x) => Transfer.fromMap(x),
                ),
              )
            : null,
        logs: map['logs'] != null
            ? List<Map<String, dynamic>>.from(map['logs'])
            : null);
  }

  String toJson() => json.encode(toMap());

  factory Transaction.fromJson(String source) =>
      Transaction.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Transfer {
  final DateTime blockSignedAt;
  final String txHash;
  final EthereumAddress fromAddress;
  final String? fromAddressLabel;
  final EthereumAddress toAddress;
  final String? toAddressLabel;
  final int contractDecimals;
  final String contractName;
  final String contractTickerSymbol;
  final EthereumAddress contractAddress;
  final String logoUrl;
  final String transferType;
  final BigInt delta;
  final EtherAmount? balance;
  final double quoteRate;
  final double deltaQuote;
  final String prettyDeltaQuote;
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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'blockSignedAt': blockSignedAt.toIso8601String(),
      'txHash': txHash,
      'fromAddress': fromAddress.hex,
      'fromAddressLabel': fromAddressLabel,
      'toAddress': toAddress.hex,
      'toAddressLabel': toAddressLabel,
      'contractDecimals': contractDecimals,
      'contractName': contractName,
      'contractTickerSymbol': contractTickerSymbol,
      'contractAddress': contractAddress.hex,
      'logoUrl': logoUrl,
      'transferType': transferType,
      'delta': delta.toString(),
      'balance': balance?.getInWei.toString(),
      'quoteRate': quoteRate,
      'deltaQuote': deltaQuote,
      'prettyDeltaQuote': prettyDeltaQuote,
      'balanceQuote': balanceQuote,
      'methodCalls': methodCalls,
    };
  }

  factory Transfer.fromMap(Map<String, dynamic> map) {
    return Transfer(
      blockSignedAt: DateTime.parse(map['blockSignedAt']),
      txHash: map['txHash'],
      fromAddress: EthereumAddress.fromHex(map['fromAddress']),
      fromAddressLabel: map['fromAddressLabel'],
      toAddress: EthereumAddress.fromHex(map['toAddress']),
      toAddressLabel: map['toAddressLabel'],
      contractDecimals: map['contractDecimals'],
      contractName: map['contractName'],
      contractTickerSymbol: map['contractTickerSymbol'],
      contractAddress: EthereumAddress.fromHex(map['contractAddress']),
      logoUrl: map['logoUrl'],
      transferType: map['transferType'],
      delta: BigInt.parse(map['delta']),
      balance: map['balance'] != null
          ? EtherAmount.fromBase10String(EtherUnit.wei, map['balance'])
          : null,
      quoteRate: map['quoteRate'],
      deltaQuote: map['deltaQuote'],
      prettyDeltaQuote: map['prettyDeltaQuote'],
      balanceQuote: map['balanceQuote'],
      methodCalls: map['methodCalls'] != null
          ? map['methodCalls'] as Map<String, dynamic>
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Transfer.fromJson(String source) =>
      Transfer.fromMap(json.decode(source) as Map<String, dynamic>);
}

class GasMetadata {
  final num contractDecimals;
  final String contractName;
  final String contractTickerSymbol;
  final EthereumAddress contractAddress;
  final List<String>? supportsErc;
  final String logoUrl;

  GasMetadata({
    required this.contractDecimals,
    required this.contractName,
    required this.contractTickerSymbol,
    required this.contractAddress,
    this.supportsErc,
    required this.logoUrl,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'contractDecimals': contractDecimals,
      'contractName': contractName,
      'contractTickerSymbol': contractTickerSymbol,
      'contractAddress': contractAddress.hex,
      'supportsErc': supportsErc,
      'logoUrl': logoUrl,
    };
  }

  factory GasMetadata.fromMap(Map<String, dynamic> map) {
    return GasMetadata(
      contractDecimals: map['contractDecimals'],
      contractName: map['contractName'],
      contractTickerSymbol: map['contractTickerSymbol'],
      contractAddress: EthereumAddress.fromHex(map['contractAddress']),
      supportsErc: map['supportsErc'] != null
          ? List<String>.from((map['supportsErc'] as List<String>))
          : null,
      logoUrl: map['logoUrl'],
    );
  }

  String toJson() => json.encode(toMap());

  factory GasMetadata.fromJson(String source) =>
      GasMetadata.fromMap(json.decode(source) as Map<String, dynamic>);
}
