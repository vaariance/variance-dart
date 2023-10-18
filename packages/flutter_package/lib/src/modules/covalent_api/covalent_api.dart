import 'package:pks_4337_sdk/src/dio_client.dart';

export 'nfts.dart';
export 'tokens.dart';
export 'transactions.dart';

class BaseCovalentApi {
  final String _apiKey;
  final Uri _baseCovalentApiUri;
  final DioClient _dioClient = DioClient();

  Uri get baseCovalentApiUri => _baseCovalentApiUri;

  BaseCovalentApi(
    this._apiKey,
    String chainName,
  ) : _baseCovalentApiUri =
            Uri.parse('https://api.covalenthq.com/v1/$chainName/');

  Future<Map<String, dynamic>> fetchApiRequest(
    String path,
    Map<String, Object?> queryParams,
  ) async {
    final String requestUrl = _baseCovalentApiUri
        .replace(path: path)
        .replace(queryParameters: queryParams)
        .toString();
    print(requestUrl);
    return await _dioClient.callCovalentApi<Map<String, dynamic>>(
        requestUrl, _apiKey);
  }
}
