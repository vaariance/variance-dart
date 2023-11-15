part of 'package:variance_dart/utils.dart';

/// HTTP client utility class using Dio for making HTTP requests.
///
/// The DioClient class provides methods to perform GET and POST requests with optional caching.
/// It utilizes the Dio library and includes error handling for DioException.
class DioClient {
  final Dio _dio = Dio()
    ..interceptors.add(DioCacheInterceptor(
      options: CacheOptions(
        store: MemCacheStore(maxSize: 10485760, maxEntrySize: 1048576),
        policy: CachePolicy.request,
        hitCacheOnErrorExcept: [401, 403],
        maxStale: const Duration(days: 1),
      ),
    ));

  /// Performs a GET request to the provided API URL and returns the response.
  ///
  /// - [apiUrl]: The URL for the GET request.
  ///
  /// Returns a [Future] that completes with the response data of type [T].
  ///
  /// Throws a [DioException] if the request fails.
  Future<T> get<T>(String apiUrl) async {
    try {
      final response = await _dio.get(apiUrl);
      return response.data as T;
    } on DioException catch (e) {
      log("message: ${e.message}");
      rethrow;
    }
  }

  /// Performs a POST request to the provided API URL with the given [body] and returns the response.
  ///
  /// - [apiUrl]: The URL for the POST request.
  /// - [body]: The request body data.
  ///
  /// Returns a [Future] that completes with the response data of type [T].
  ///
  /// Throws a [DioException] if the request fails.
  Future<T> post<T>(String apiUrl, dynamic body) async {
    try {
      final response = await _dio.post(apiUrl, data: body);
      return response.data as T;
    } on DioException catch (e) {
      log("message: ${e.message}");
      rethrow;
    }
  }
}

