import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

class DioClient {
  final _dio = Dio()
    ..interceptors.add(DioCacheInterceptor(
      options: CacheOptions(
        store: MemCacheStore(maxSize: 10485760, maxEntrySize: 1048576),
        policy: CachePolicy.request,
        hitCacheOnErrorExcept: [401, 403],
        maxStale: const Duration(days: 1),
      ),
    ));
  /// [callWithSyncFeeErc2771] calls the ERC2771 API with a sync fee
  /// - @param [relayEndpointUrl] is the relay endpoint url
  /// - @param [data] is the data to send to the relay endpoint
  Future callWithSyncFeeErc2771<T>(
      String relayEndpointUrl, Map<String, dynamic> data) async {
    try {
      await _dio.post(
        relayEndpointUrl,
        data: data,
      );
    } on DioException catch (e) {
      log(e.message!);
      rethrow;
    }
  }
  /// [callNftApi] calls the NFT API
  Future<T> callNftApi<T>(String nftApiUrl) async {
    try {
      final response = await _dio.get(nftApiUrl);
      return response.data as T;
    } on DioException catch (e) {
      log(e.message!);
      rethrow;
    }
  }
}
