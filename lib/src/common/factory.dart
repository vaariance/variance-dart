part of '../../variance.dart';

class _AccountFactory extends AccountFactory implements AccountFactoryBase {
  _AccountFactory(
      {required super.address, super.chainId, required RPCProviderBase rpc})
      : super(client: Web3Client.custom(rpc));
}
