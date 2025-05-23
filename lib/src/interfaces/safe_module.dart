part of 'interfaces.dart';

abstract class Safe4337ModuleBase {
  // ignore: non_constant_identifier_names
  Future<EthereumAddress> SUPPORTED_ENTRYPOINT({BlockNum? atBlock});

  Future<String> executeUserOpWithErrorString(
    ({EthereumAddress to, BigInt value, Uint8List data, BigInt operation})
    args, {
    required Credentials credentials,
    Transaction? transaction,
  });

  Future<String> executeUserOp(
    ({EthereumAddress to, BigInt value, Uint8List data, BigInt operation})
    args, {
    required Credentials credentials,
    Transaction? transaction,
  });

  Future<Uint8List> getOperationHash(
    ({dynamic userOp}) args, {
    BlockNum? atBlock,
  });
}
