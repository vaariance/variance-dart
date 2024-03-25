part of '../../variance.dart';

class _SimpleAccountFactory extends SimpleAccountFactory
    implements SimpleAccountFactoryBase {
  _SimpleAccountFactory(
      {required super.address, super.chainId, required RPCBase rpc})
      : super(client: Web3Client.custom(rpc));
}

class _P256AccountFactory extends P256AccountFactory
    implements P256AccountFactoryBase {
  _P256AccountFactory(
      {required super.address, super.chainId, required RPCBase rpc})
      : super(client: Web3Client.custom(rpc));
}
