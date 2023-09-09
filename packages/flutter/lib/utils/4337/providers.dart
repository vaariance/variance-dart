import 'package:web3dart/json_rpc.dart';
import 'package:http/http.dart' as http;
import "../common.dart";
import 'EIP_4337.dart';

class BaseProvider extends JsonRPC {
  BaseProvider(super.url, super.client);

  Future<T> _makeRPCCall<T>(String function, [List<dynamic>? params]) async {
    try {
      final data = await super.call(function, params);
      // ignore: only_throw_errors
      if (data is Error || data is Exception) throw data;

      return data.result as T;
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      rethrow;
    }
  }

  Future<T> send<T>(String function, [List<dynamic>? params]) async {
    return await _makeRPCCall<T>(function, params);
  }
}

class BundlerProvider {
  final int _chainId;
  final String _bundlerUrl;
  final BaseProvider _bundlerClient;
  late bool _initialized;

  BundlerProvider(int chainId, String bundlerUrl)
      : _chainId = chainId,
        _bundlerUrl = bundlerUrl,
        _bundlerClient = BaseProvider(bundlerUrl, http.Client()) {
    validateBundlerChainId();
  }

  static final Set<String> methods = {
    'eth_chainId',
    'eth_sendUserOperation',
    'eth_estimateUserOperationGas',
    'eth_getUserOperationByHash',
    'eth_getUserOperationReceipt',
    'eth_supportedEntryPoints',
  };

  static validateBundlerMethod(String method) {
    require(methods.contains(method),
        "validateMethod: method ::'$method':: is not a valid method");
  }

  Future validateBundlerChainId() async {
    final chainId = await _bundlerClient
        .send<String>('eth_chainId')
        .then(BigInt.parse)
        .then((value) => value.toInt());
    require(chainId == _chainId,
        "bundler $_bundlerUrl is on chainId $chainId, but provider is on chainId $_chainId");
    _initialized = true;
  }

  // TODO: add explicit return type
  Future getUserOpReceipt(String userOpHash) async {
    require(_initialized, "getUserOp: BundlerClient not initialized");
    return await _bundlerClient
        .send('eth_getUserOperationReceipt', [userOpHash]);
  }

  // TODO: add explicit return type
  Future getUserOperationByHash(String userOpHash) async {
    require(_initialized, "getUserOp: BundlerClient not initialized");
    return await _bundlerClient
        .send('eth_getUserOperationByHash', [userOpHash]);
  }

  // TODO: add explicit return type
  Future supportedEntryPoints() async {
    return await _bundlerClient.send('eth_supportedEntryPoints');
  }

  // TODO: add explicit return type
  Future estimateUserOperationGas(UserOperation userOp) async {
    require(_initialized, "getUserOp: BundlerClient not initialized");
    return await _bundlerClient.send('eth_estimateUserOperationGas', [userOp]);
  }

// TODO: add explicit return type
  Future sendUserOperation(UserOperation userOp) async {
    require(_initialized, "getUserOp: BundlerClient not initialized");
    return await _bundlerClient.send('eth_sendUserOperation', [userOp]);
  }
}
