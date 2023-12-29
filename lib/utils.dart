library utils;

import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/types/auth_messages_ios.dart';
import 'package:variance_dart/interfaces.dart';
import 'package:variance_dart/variance.dart' show Chain;
import 'package:web3dart/web3dart.dart' show BlockNum, EthereumAddress;
import 'package:webcrypto/webcrypto.dart';

import 'src/utils/models/ens.dart';
import 'src/utils/models/metadata.dart';
import 'src/utils/models/nft.dart';
import 'src/utils/models/price.dart';
import 'src/utils/models/token.dart';
import 'src/utils/models/transaction.dart';
import 'src/utils/models/transfer.dart';

export 'package:dio/dio.dart' show BaseOptions;

export 'src/utils/models/ens.dart';
export 'src/utils/models/metadata.dart';
export 'src/utils/models/nft.dart';
export 'src/utils/models/price.dart';
export 'src/utils/models/token.dart';
export 'src/utils/models/transaction.dart';
export 'src/utils/models/transfer.dart';

part 'src/utils/chainbase_api.dart';
part 'src/utils/crypto.dart';
part 'src/utils/dio_client.dart';
part 'src/utils/local_authentication.dart';
part 'src/utils/secure_storage_repository.dart';
