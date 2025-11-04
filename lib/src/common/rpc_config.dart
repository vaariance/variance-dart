part of '../../variance_dart.dart';

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
