library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:eip1559/eip1559.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/json_rpc.dart';

import 'src/abis/abis.dart';
import 'src/interfaces/interfaces.dart';

export 'src/abis/abis.dart' show ContractAbis, Safe7579Abis;

// 4337
part 'src/4337/chains.dart';
part 'src/4337/factory.dart';
part 'src/4337/base_provider.dart';
part 'src/4337/safe.dart';
part 'src/4337/userop.dart';
part 'src/4337/wallet.dart';

// common
part 'src/common/addresses.dart';
part 'src/common/factories.dart';
part 'src/common/contract.dart';
part 'src/common/pack.dart';
part 'src/common/string.dart';
part 'src/common/extensions.dart';

// actions
part 'src/actions/7579_actions.dart';
part 'src/actions/bundler_actions.dart';
part 'src/actions/gas_overrides_actions.dart';
part 'src/actions/jsonRpc_actions.dart';
part 'src/actions/paymaster_actions.dart';
part 'src/actions/call_actions.dart';

// 7579
part 'src/7579/safe.dart';
part 'src/7579/utils.dart';
part 'src/7579/constants.dart';

part 'src/errors/wallet_errors.dart';
