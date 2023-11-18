part of 'package:variance_dart/utils.dart';

class DioClient implements RestClient {
  final Dio _dio = Dio()
    ..interceptors.add(DioCacheInterceptor(
      options: CacheOptions(
        store: MemCacheStore(maxSize: 10485760, maxEntrySize: 1048576),
        policy: CachePolicy.request,
        hitCacheOnErrorExcept: [401, 403],
        maxStale: const Duration(days: 1),
      ),
    ));

  DioClient({BaseOptions? baseOptions}) {
    _dio.options = baseOptions ??
        BaseOptions(
          contentType: 'application/json',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 60),
        );
  }

  @override
  Future<T> get<T>(String path,
      {Object? body,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    try {
      final response = await _dio.get<T>(
        path,
        data: body,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      log("message: ${e.message}");
      rethrow;
    }
  }

  @override
  Future<T> post<T>(String path,
      {Object? body,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    try {
      final response = await _dio.post<T>(path,
          data: body, queryParameters: queryParameters, options: options);
      return response.data as T;
    } on DioException catch (e) {
      log("message: ${e.message}");
      rethrow;
    }
  }
}

/// Rest client utility class using Dio for making HTTP requests over Rest Endpoints.
///
/// The RestClient class provides methods to perform GET and POST requests with additional caching.
/// It utilizes the Dio library and includes error handling for DioException.
/// The RestClient class is mainly used by the ChainBaseApi class to make requests to the ChainBase API.
abstract class RestClient {
  /// Performs a GET request to the provided API URL and returns the response.
  ///
  /// -  [path]: The URL for the GET request.
  /// - [body]: (optional) request body.
  /// - [queryParameters]: (optional) The query parameters for the GET request.
  /// - [options]: (optional) The options to be merged with the base options.
  ///
  /// Returns a [Future] that completes with the response data of type [T].
  ///
  /// Throws a [DioException] if the request fails.
  Future<T> get<T>(String path,
      {Object? body, Map<String, dynamic>? queryParameters, Options? options});

  /// Performs a POST request to the provided API URL with the given [body] and returns the response.
  ///
  /// - [path]: The URL for the POST request.
  /// - [body]: (optional) The request body.
  /// - [queryParameters]: (optional) The query parameters for the POST request.
  /// - [options]: (optional) The options to be merged with the base options.
  ///
  /// Returns a [Future] that completes with the response data of type [T].
  ///
  /// Throws a [DioException] if the request fails.
  Future<T> post<T>(String path,
      {Object? body, Map<String, dynamic>? queryParameters, Options? options});
}
