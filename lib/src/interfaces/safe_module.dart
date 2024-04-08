part of 'interfaces.dart';

abstract class Safe4337ModuleBase {
  Future<EthereumAddress> SUPPORTED_ENTRYPOINT({BlockNum? atBlock});

  Future<String> executeUserOpWithErrorString(
    EthereumAddress to,
    BigInt value,
    Uint8List data,
    BigInt operation, {
    required Credentials credentials,
    Transaction? transaction,
  });

  Future<String> executeUserOp(
    EthereumAddress to,
    BigInt value,
    Uint8List data,
    BigInt operation, {
    required Credentials credentials,
    Transaction? transaction,
  });

  Future<Uint8List> getOperationHash(
    dynamic userOp, {
    BlockNum? atBlock,
  });
}
