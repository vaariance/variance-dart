import 'dart:convert';
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
  Future callWithSyncFeeErc2771(
      String relayEndpointUrl, Map<String, dynamic> data) async {
    try {
      await _dio.post(
        relayEndpointUrl,
        data: data,
      );
    } on DioException catch (e) {
      log("message: ${e.message}");
      rethrow;
    }
  }

  /// [callWeb3Api] calls the provided API url and returns the response.
  Future<T> callWeb3Api<T>(String apiUrl) async {
    try {
      final response = await _dio.get(apiUrl);
      return response.data as T;
    } on DioException catch (e) {
      log("message: ${e.message}");
      rethrow;
    }
  }

  /// [callCovalentApi] calls a covalent endpoint and returns the response.
  /// - @param [apiUrl] is the covalent endpoint url
  /// - @param [apiKey] is the covalent api key
  Future<T> callCovalentApi<T>(String apiUrl, String apiKey) async {
    _dio.options.headers = {
      "Authorization": "Basic ${base64Encode(utf8.encode("$apiKey:"))}",
      'Content-Type': 'application/json'
    };
    try {
      final response = await _dio.get(apiUrl);
      return response.data as T;
    } on DioException catch (e) {
      log("message: ${e.message}");
      rethrow;
    }
  }
}
