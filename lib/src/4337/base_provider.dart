part of '../../variance_dart.dart';

typedef RpcConfig = ({String url, Map<String, String>? headers});

class RPCBase extends JsonRPC {
  RPCBase(String url, {Map<String, String>? headers})
    : super(
        url,
        headers != null ? HeaderClient(http.Client(), headers) : http.Client(),
      );

  factory RPCBase.fromConfig(RpcConfig config) {
    return RPCBase(config.url, headers: config.headers ?? {});
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

class HeaderClient extends http.BaseClient {
  HeaderClient(this._inner, this._headers);
  final http.Client _inner;
  final Map<String, String> _headers;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    _headers.forEach((key, value) {
      request.headers[key] = value;
    });
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
