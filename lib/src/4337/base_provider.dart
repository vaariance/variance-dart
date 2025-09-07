part of '../../variance_dart.dart';

class RPCBase extends JsonRPC {
  final Map<String, String>? headers;

  RPCBase(String url, {this.headers})
    : super(url, _createHttpClient(url, headers));

  factory RPCBase.fromConfig(RPCEndpointConfig config) {
    return RPCBase(config.url, headers: config.headers);
  }

  /// Create HTTP client with custom headers if provided
  static http.Client _createHttpClient(
    String? url,
    Map<String, String>? headers,
  ) {
    final client = http.Client();
    if (headers != null && headers.isNotEmpty) {
      return HeaderInterceptorClient(client, headers);
    }
    return client;
  }

  /// Asynchronously sends an RPC call to the Ethereum node for the specified function and parameters.
  ///
  /// Parameters:
  ///   - `function`: The Ethereum RPC function to call. eg: `eth_getBalance`
  ///   - `params`: Optional parameters for the RPC call.
  ///
  /// Returns:
  ///   A [Future] that completes with the result of the RPC call.
  ///
  /// Example:
  /// ```dart
  /// var result = await send<String>('eth_getBalance', ['0x9876543210abcdef9876543210abcdef98765432']);
  /// ```
  Future<T> send<T>(String function, [List<dynamic>? params]) {
    return _makeRPCCall<T>(function, params);
  }

  Future<T> _makeRPCCall<T>(String function, [List<dynamic>? params]) {
    return super.call(function, params).then((data) => data.result as T);
  }
}
