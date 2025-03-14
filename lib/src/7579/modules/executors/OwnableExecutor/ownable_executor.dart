// ignore_for_file: public_member_api_docs, sort_constructors_first
part of '../../module.dart';

class OwnableExecutor extends ExecutorModuleInterface {
  OwnableExecutor(super.wallet);

  @override
  String get name => 'OwnableExecutor';

  @override
  String get version => '1.0.0';

  @override
  ModuleType get type => ModuleType.executor;

  @override
  EthereumAddress get address => getAddress();

  @override
  Uint8List get initData => getInitData();

  Future<UserOperationReceipt?> addOwner(EthereumAddress owner) async {
    final calldata =
        _deployedModule.contract.function('addOwner').encodeCall([owner]);
    final tx = await wallet.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> removeOwner(EthereumAddress owner) async {
    final oowners = await getOwners() ?? [];
    final currentOwnerIndex = oowners.indexOf(owner);

    EthereumAddress prevOwner;
    if (currentOwnerIndex == -1) {
      throw Exception('Owner not found');
    } else if (currentOwnerIndex == 0) {
      prevOwner = SENTINEL_ADDRESS;
    } else {
      prevOwner = oowners[currentOwnerIndex - 1];
    }
    final calldata = _deployedModule.contract
        .function('removeOwner')
        .encodeCall([prevOwner, owner]);
    final tx = await wallet.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<List<EthereumAddress>?> getOwners([EthereumAddress? account]) async {
    final result = await wallet.readContract(
        address, ownable_executor_abi, 'getOwners',
        params: [account ?? wallet.address]);
    return result.firstOrNull;
  }

  Future<UserOperationReceipt?> executeOnOwnedAccount(
      SmartWallet ownedAccount, Uint8List data) async {
    final calldata = _deployedModule.contract
        .function('executeOnOwnedAccount')
        .encodeCall([ownedAccount.address, data]);
    final tx = await wallet.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> executeBatchOnOwnedAccount(
      SmartWallet ownedAccount, Uint8List data) async {
    final calldata = _deployedModule.contract
        .function('executeBatchOnOwnedAccount')
        .encodeCall([ownedAccount, data]);
    final tx = await wallet.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<BigInt?> ownerCount([EthereumAddress? account]) async {
    final result = await wallet.readContract(
        address, ownable_executor_abi, 'ownerCount',
        params: [account ?? wallet.address]);
    return result.firstOrNull;
  }

  final _deployedModule = OwnableExecutorContract(getAddress());

  // must be static
  static Uint8List getInitData() {
    return getAddress().addressBytes;
  }

  // must be static
  static EthereumAddress getAddress() {
    return EthereumAddress.fromHex(
        '0x4Fd8d57b94966982B62e9588C27B4171B55E8354');
  }
}
