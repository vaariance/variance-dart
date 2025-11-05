part of '../../variance_dart.dart';

typedef HeaderMap = Map<String, String>;
typedef RpcConfig = ({String url, HeaderMap? headers});

class HeaderClient extends http.BaseClient {
  final http.Client _inner;
  final HeaderMap _headers;

  HeaderClient(this._inner, this._headers);

  @override
  void close() {
    _inner.close();
    super.close();
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    _headers.forEach((k, v) {
      request.headers.putIfAbsent(k, () => v);
    });
    return _inner.send(request);
  }
}

class RPCBase extends JsonRPC {
  RPCBase(RpcConfig config) : super(config.url, _getClient(config.headers));

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

  static http.Client _getClient(HeaderMap? headers) {
    final client = http.Client();
    if (headers != null) {
      return HeaderClient(client, headers);
    }
    return client;
  }
}
