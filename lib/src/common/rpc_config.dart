part of '../../variance_dart.dart';

class RPConfig {
  final String url;
  final Map<String, String>? headers;

  const RPConfig({required this.url, this.headers});

  factory RPConfig.fromUrl(String url) {
    return RPConfig(url: url);
  }

  factory RPConfig.withClientId({
    required String url,
    required String clientId,
  }) {
    return RPConfig(
      url: url,
      headers: {
        'x-client-id': clientId,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }
}

class HeaderInterceptorClient extends http.BaseClient {
  final http.Client _inner;
  final Map<String, String> _headers;

  HeaderInterceptorClient(this._inner, this._headers);

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
