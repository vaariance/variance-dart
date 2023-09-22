import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer';

void main() async {
  await DotEnv().load(fileName: '.env');
}

class DioClient {
  final Dio _dio = Dio();
  final _baseUrl = 'https://api.gelato.digital';
  final String? publicApiKey;

  DioClient({String? publicApiKey})
      : publicApiKey = publicApiKey ?? dotenv.env['.env'];

  Future<String> callWithSyncFeeErc2771() async {
    try {
      // ignore: unused_local_variable
      final response = await _dio
          .post('$_baseUrl/relays/v2/call-with-sync-fee-erc2771', data: {
        "chainId": 0,
        "target": "string",
        "data": "string",
        "user": "string",
        "userNonce": 0,
        "userDeadline": 0,
        "userSignature": "string",
        "sponsorApiKey": "string",
        "gasLimit": "string",
        "retries": 0
      });
    } on DioException catch (e) {
      log(e.message!);
    }

    const message = ''; // You can change this message as needed
    return message;
  }
}
