library interfaces;

import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:variance_dart/utils.dart'
    show
        SSAuthOperationOptions,
        ChainBaseApiBase,
        CredentialType,
        SecureStorageMiddleware;
import 'package:web3dart/crypto.dart';
import 'package:web3dart/json_rpc.dart' show RpcService;
import 'package:web3dart/web3dart.dart';

import 'src/abis/abis.dart' show Entrypoint;
import 'variance.dart'
    show
        Chain,
        PassKeyPair,
        PassKeySignature,
        PassKeysOptions,
        Uint256,
        UserOperation,
        UserOperationByHash,
        UserOperationGas,
        UserOperationReceipt,
        UserOperationResponse;

part 'src/interfaces/account_factory.dart';
part 'src/interfaces/bundler_provider.dart';
part 'src/interfaces/credential_interface.dart';
part 'src/interfaces/ens_resolver.dart';
part 'src/interfaces/hd_interface.dart';
part 'src/interfaces/local_authentication.dart';
part 'src/interfaces/multi_signer_interface.dart';
part 'src/interfaces/passkey_interface.dart';
part 'src/interfaces/rpc_provider.dart';
part 'src/interfaces/secure_storage_repository.dart';
part 'src/interfaces/smart_wallet.dart';
part 'src/interfaces/uint256_interface.dart';
part 'src/interfaces/user_operations.dart';
