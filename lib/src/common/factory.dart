part of '../../variance.dart';

class _SimpleAccountFactory extends AccountFactory
    implements AccountFactoryBase {
  _SimpleAccountFactory(
      {required super.address, super.chainId, required RPCBase rpc})
      : super(client: Web3Client.custom(rpc));
}
