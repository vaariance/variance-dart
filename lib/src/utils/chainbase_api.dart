part of 'package:variance_dart/utils.dart';

class ChainBaseApi implements ChainBaseApiBase {
  final RestClient _restClient;
  final Chain _chain;

  ChainBaseApi({required RestClient restClient, required Chain chain})
      : _restClient = restClient,
        _chain = chain;

  @override
  Future<TokenPriceResponse> getERC20TokenMarketPrice(
      EthereumAddress tokenAddress) async {
    return TokenPriceResponse.fromJson(await _restClient
        .get<Map<String, dynamic>>('/token/price', queryParameters: {
      'contract_address': tokenAddress.hex,
      'chain_id': _chain.chainId
    }));
  }

  @override
  Future<NFTBalancesResponse> getNFTBalancesForAddress(
    EthereumAddress address, {
    EthereumAddress? tokenAddress,
    int page = 1,
    int pageSize = 20,
  }) async {
    return NFTBalancesResponse.fromJson(await _restClient
        .get<Map<String, dynamic>>('/account/nfts', queryParameters: {
      'address': address.hex,
      'chain_id': _chain.chainId,
      if (tokenAddress != null) 'contract_address': tokenAddress.hex,
      'page': page,
      'limit': pageSize,
    }));
  }

  @override
  Future<TokenBalancesResponse> getTokenBalancesForAddress(
      EthereumAddress address,
      {EthereumAddress? tokenAddress,
      int page = 1,
      int pageSize = 20}) async {
    return TokenBalancesResponse.fromJson(await _restClient
        .get<Map<String, dynamic>>('/account/tokens', queryParameters: {
      'address': address.hex,
      'chain_id': _chain.chainId,
      if (tokenAddress != null) 'contract_address': tokenAddress.hex,
      'page': page,
      'limit': pageSize,
    }));
  }

  @override
  Future<TokenTransfersResponse> getTokenTransfersForAddress(
    EthereumAddress address, {
    EthereumAddress? tokenAddress,
    BlockNum? fromBlock,
    BlockNum? toBlock,
    DateTime? fromTime,
    DateTime? toTime,
    int page = 1,
    int pageSize = 20,
  }) async {
    return TokenTransfersResponse.fromJson(
        await _restClient
            .get<Map<String, dynamic>>('/token/transfers', queryParameters: {
          'address': address.hex,
          'chain_id': _chain.chainId,
          if (tokenAddress != null) 'contract_address': tokenAddress.hex,
          if (fromBlock != null) 'from_block': fromBlock.toBlockParam(),
          if (toBlock != null) 'to_block': toBlock.toBlockParam(),
          if (fromTime != null)
            'from_timestamp': fromTime.millisecondsSinceEpoch,
          if (toTime != null) 'end_timestamp': toTime.millisecondsSinceEpoch,
          'page': page,
          'limit': pageSize,
        }),
        address.hex);
  }

  @override
  Future<TransactionsResponse> getTransactionsForAddress(
    EthereumAddress address, {
    EthereumAddress? tokenAddress,
    BlockNum? fromBlock,
    BlockNum? toBlock,
    DateTime? fromTime,
    DateTime? toTime,
    int page = 1,
    int pageSize = 20,
  }) async {
    return TransactionsResponse.fromJson(await _restClient
        .get<Map<String, dynamic>>('/account/txs', queryParameters: {
      'address': address.hex,
      'chain_id': _chain.chainId,
      if (tokenAddress != null) 'contract_address': tokenAddress.hex,
      if (fromBlock != null) 'from_block': fromBlock.toBlockParam(),
      if (toBlock != null) 'to_block': toBlock.toBlockParam(),
      if (fromTime != null) 'from_timestamp': fromTime.millisecondsSinceEpoch,
      if (toTime != null) 'end_timestamp': toTime.millisecondsSinceEpoch,
      'page': page,
      'limit': pageSize,
    }));
  }

  @override
  Future<ENSResponse> resolveENSName(String name, {BlockNum? toBlock}) async {
    return ENSResponse.fromJson(await _restClient
        .get<Map<String, dynamic>>('/ens/records', queryParameters: {
      'domain': name,
      'chain_id': 1,
      if (toBlock != null) 'to_block': toBlock.toBlockParam()
    }));
  }

  @override
  Future<ENSResponse> reverseENSAddress(EthereumAddress address,
      {BlockNum? toBlock}) async {
    return ENSResponse.fromJson(await _restClient
        .get<Map<String, dynamic>>('/ens/reverse', queryParameters: {
      'address': address,
      'chain_id': 1,
      if (toBlock != null) 'to_block': toBlock.toBlockParam()
    }));
  }
}

/// An abstract class representing the base API for interacting with a blockchain.
///
/// This class defines methods for retrieving various information related to
/// ERC-20 tokens, NFT balances, token balances, token transfers, transactions,
/// ENS name resolution, and reverse ENS address lookup.
abstract class ChainBaseApiBase {
  /// Retrieves the market price of an ERC-20 token.
  ///
  /// Given the [tokenAddress], this method returns a [TokenPriceResponse]
  /// containing information about the market price of the token.
  Future<TokenPriceResponse> getERC20TokenMarketPrice(
      EthereumAddress tokenAddress);

  /// Retrieves NFT balances for a specific address.
  ///
  /// Given the [address], this method returns a [NFTBalancesResponse] with
  /// information about NFT balances. Additional parameters like [tokenAddress],
  /// [page], and [pageSize] can be specified for more targeted results.
  Future<NFTBalancesResponse> getNFTBalancesForAddress(
    EthereumAddress address, {
    EthereumAddress? tokenAddress,
    int page = 1,
    int pageSize = 20,
  });

  /// Retrieves token balances for a specific address.
  ///
  /// Given the [address], this method returns a [TokenBalancesResponse] with
  /// information about the token balances. Additional parameters like [tokenAddress],
  /// [page], and [pageSize] can be specified for more targeted results.
  Future<TokenBalancesResponse> getTokenBalancesForAddress(
      EthereumAddress address,
      {EthereumAddress? tokenAddress,
      int page = 1,
      int pageSize = 20});

  /// Retrieves token transfers for a specific address and token.
  ///
  /// Given the [address] and [tokenAddress], this method returns a
  /// [TokenTransfersResponse] with information about token transfers. Additional
  /// parameters like [fromBlock], [toBlock], [fromTime], [toTime], [page], and
  /// [pageSize] can be specified for more targeted results.
  Future<TokenTransfersResponse> getTokenTransfersForAddress(
    EthereumAddress address, {
    EthereumAddress? tokenAddress,
    BlockNum? fromBlock,
    BlockNum? toBlock,
    DateTime? fromTime,
    DateTime? toTime,
    int page = 1,
    int pageSize = 20,
  });

  /// Retrieves transactions for a specific address.
  ///
  /// Given the [address], this method returns a [TransactionsResponse]
  /// containing information about transactions related to the address. Additional
  /// parameters like [fromBlock], [toBlock], [fromTime], [toTime], [page], and
  /// [pageSize] can be specified for more targeted results.
  Future<TransactionsResponse> getTransactionsForAddress(
    EthereumAddress address, {
    EthereumAddress? tokenAddress,
    BlockNum? fromBlock,
    BlockNum? toBlock,
    DateTime? fromTime,
    DateTime? toTime,
    int page = 1,
    int pageSize = 20,
  });

  /// Resolves an ENS name to its corresponding Ethereum address.
  ///
  /// Given the [name], this method returns an [ENSResponse] containing
  /// information about the Ethereum address associated with the ENS name.
  Future<ENSResponse> resolveENSName(String name, {BlockNum? toBlock});

  /// Performs a reverse ENS address lookup to obtain the associated ENS name.
  ///
  /// Given the [address], this method returns an [ENSResponse] with
  /// information about the ENS name associated with the Ethereum address.
  Future<ENSResponse> reverseENSAddress(EthereumAddress address,
      {BlockNum? toBlock});
}

class ChainBaseResponse {
  final int code;
  final String message;
  final int? nextPageNumber;
  final int? count;

  ChainBaseResponse({
    required this.code,
    required this.message,
    this.nextPageNumber,
    this.count,
  });
}

class ENSResponse extends ChainBaseResponse {
  final ENS? data;
  ENSResponse({
    required super.code,
    required super.message,
    this.data,
    super.nextPageNumber,
    super.count,
  });

  factory ENSResponse.fromJson(Map<String, dynamic> json) {
    return ENSResponse(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? json['data'] is List
              ? ENS.fromJson(json['data'][0])
              : ENS.fromJson(json['data'])
          : null,
      nextPageNumber: json['next_page'],
      count: json['count'],
    );
  }
}

class NFTBalancesResponse extends ChainBaseResponse {
  final List<NFT>? data;
  NFTBalancesResponse({
    required super.code,
    required super.message,
    this.data,
    super.nextPageNumber,
    super.count,
  });

  factory NFTBalancesResponse.fromJson(Map<String, dynamic> json) {
    return NFTBalancesResponse(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? List<NFT>.from(json['data'].map((x) => NFT.fromJson(x)))
          : null,
      nextPageNumber: json['next_page'],
      count: json['count'],
    );
  }
}

class TokenBalancesResponse extends ChainBaseResponse {
  final List<Token>? data;
  TokenBalancesResponse({
    required super.code,
    required super.message,
    this.data,
    super.nextPageNumber,
    super.count,
  });

  factory TokenBalancesResponse.fromJson(Map<String, dynamic> json) {
    return TokenBalancesResponse(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? List<Token>.from(json['data'].map((x) => Token.fromJson(x)))
          : null,
      nextPageNumber: json['next_page'],
      count: json['count'],
    );
  }
}

class TokenPriceResponse extends ChainBaseResponse {
  final TokenPrice? data;
  TokenPriceResponse({
    required super.code,
    required super.message,
    this.data,
    super.nextPageNumber,
    super.count,
  });

  factory TokenPriceResponse.fromJson(Map<String, dynamic> json) {
    return TokenPriceResponse(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? TokenPrice.fromJson(json['data']) : null,
      nextPageNumber: json['next_page'],
      count: json['count'],
    );
  }
}

class TokenTransfersResponse extends ChainBaseResponse {
  final List<TokenTransfer>? data;
  TokenTransfersResponse({
    required super.code,
    required super.message,
    this.data,
    super.nextPageNumber,
    super.count,
  });

  factory TokenTransfersResponse.fromJson(
      Map<String, dynamic> json, String caller) {
    Map<String, dynamic> getModifiedJson(Map<String, dynamic> json) {
      if (json['from_address'].toLowerCase() == caller.toLowerCase()) {
        json['direction'] = 'SEND';
      } else {
        json['direction'] = 'RECEIVE';
      }
      return json;
    }

    return TokenTransfersResponse(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? List<TokenTransfer>.from(json['data']
              .map((x) => TokenTransfer.fromJson(getModifiedJson(x))))
          : null,
      nextPageNumber: json['next_page'],
      count: json['count'],
    );
  }
}

class TransactionsResponse extends ChainBaseResponse {
  final List<Transaction>? data;
  TransactionsResponse({
    required super.code,
    required super.message,
    this.data,
    super.nextPageNumber,
    super.count,
  });

  factory TransactionsResponse.fromJson(Map<String, dynamic> json) {
    return TransactionsResponse(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? List<Transaction>.from(
              json['data'].map((x) => Transaction.fromJson(x)))
          : null,
      nextPageNumber: json['next_page'],
      count: json['count'],
    );
  }
}
