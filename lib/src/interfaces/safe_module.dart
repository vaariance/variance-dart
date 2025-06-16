part of 'interfaces.dart';

abstract class Safe4337ModuleBase {
  // ignore: non_constant_identifier_names
  Future<Address> SUPPORTED_ENTRYPOINT({BlockNum? atBlock});

  Future<String> executeUserOpWithErrorString(
    ({Address to, BigInt value, Uint8List data, BigInt operation}) args, {
    required Credentials credentials,
    Transaction? transaction,
  });

  Future<String> executeUserOp(
    ({Address to, BigInt value, Uint8List data, BigInt operation}) args, {
    required Credentials credentials,
    Transaction? transaction,
  });

  Future<Uint8List> getOperationHash(
    ({dynamic userOp}) args, {
    BlockNum? atBlock,
  });
}
