// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/4337/modules/enum.dart';
import 'package:web3dart/web3dart.dart';

/// uses alchemy transfer api
/// if want to use another api, you have to create a custom class
class Transfers {
  final BaseProvider _provider;

  Transfers(this._provider);

  Future<TransferResponse> _getAssetTransfers(
      {Uint256? fromBlock,
      Uint256? toBlock,
      EthereumAddress? from,
      EthereumAddress? to,
      bool orderByDesc = false,
      bool withMetadata = false,
      bool excludeZeroValue = false,
      Uint256? maxCount,
      String? pageKey,
      List<TransferCategory>? categories,
      List<EthereumAddress>? addresses}) async {
    final params = {
      "fromBlock": fromBlock?.value ?? BigInt.zero,
      "toBlock": toBlock?.value ?? "latest",
      "order": orderByDesc ? "desc" : "asc",
      "withMetadata": withMetadata,
      "excludeZeroValue": excludeZeroValue,
      "maxCount": maxCount?.toHex() ?? "0x3e8",
      "category":
          categories?.map((e) => e.name).toList(growable: false) ?? ["external"]
    };
    if (pageKey != null) {
      params['pageKey'] = pageKey;
    }
    if (addresses != null) {
      params['contractAddresses'] =
          addresses.map((e) => e.hex).toList(growable: false);
    }
    from != null
        ? params['fromAddress'] = from.hex
        : params['toAddress'] = to!.hex;
    final response = await _provider
        .send<Map<String, dynamic>>('alchemy_getAssetTransfers', [params]);
    return TransferResponse.fromMap(
        response,
        withMetadata
            ? ResponseType.withMetadata
            : ResponseType.withoutMetadata);
  }

  Future<List<Transfer>> getAssetTransfers(EthereumAddress owner,
      {Uint256? fromBlock,
      Uint256? toBlock,
      bool orderByDesc = false,
      bool withMetadata = false,
      bool excludeZeroValue = false,
      Uint256? maxCount,
      String? pageKey}) {
    return getIncomingTransfers(owner).then((res) async {
      res.transfers.addAll(
          await getOutgoingTransfers(owner).then((res2) => res2.transfers));
      return res.transfers;
    });
  }

  Future<TransferResponse> getOutgoingTransfers(EthereumAddress owner,
      {Uint256? fromBlock,
      Uint256? toBlock,
      bool orderByDesc = false,
      bool withMetadata = false,
      bool excludeZeroValue = false,
      Uint256? maxCount,
      String? pageKey}) {
    return _getAssetTransfers(
        fromBlock: fromBlock,
        toBlock: toBlock,
        orderByDesc: orderByDesc,
        withMetadata: withMetadata,
        excludeZeroValue: excludeZeroValue,
        maxCount: maxCount,
        pageKey: pageKey,
        from: owner);
  }

  Future<TransferResponse> getIncomingTransfers(EthereumAddress owner,
      {Uint256? fromBlock,
      Uint256? toBlock,
      bool orderByDesc = false,
      bool withMetadata = false,
      bool excludeZeroValue = false,
      Uint256? maxCount,
      String? pageKey}) {
    return _getAssetTransfers(
        fromBlock: fromBlock,
        toBlock: toBlock,
        orderByDesc: orderByDesc,
        withMetadata: withMetadata,
        excludeZeroValue: excludeZeroValue,
        maxCount: maxCount,
        pageKey: pageKey,
        to: owner);
  }

  Future<TransferResponse> getTransfersByCategory(
      EthereumAddress owner, List<TransferCategory> categories,
      {Uint256? fromBlock,
      Uint256? toBlock,
      bool orderByDesc = false,
      bool withMetadata = false,
      bool excludeZeroValue = false,
      Uint256? maxCount,
      String? pageKey}) {
    return _getAssetTransfers(
        fromBlock: fromBlock,
        toBlock: toBlock,
        orderByDesc: orderByDesc,
        withMetadata: withMetadata,
        excludeZeroValue: excludeZeroValue,
        maxCount: maxCount,
        pageKey: pageKey,
        categories: categories,
        from: owner);
  }

  Future getTransfersByContracts(
      EthereumAddress owner, List<EthereumAddress> addresses,
      {Uint256? fromBlock,
      Uint256? toBlock,
      bool orderByDesc = false,
      bool withMetadata = false,
      bool excludeZeroValue = false,
      Uint256? maxCount,
      String? pageKey}) {
    return _getAssetTransfers(
      fromBlock: fromBlock,
      toBlock: toBlock,
      orderByDesc: orderByDesc,
      withMetadata: withMetadata,
      excludeZeroValue: excludeZeroValue,
      maxCount: maxCount,
      pageKey: pageKey,
      from: owner,
      addresses: addresses,
    );
  }
}
