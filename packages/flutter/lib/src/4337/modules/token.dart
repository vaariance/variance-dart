import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/4337/modules/contract.dart';
import 'package:pks_4337_sdk/src/4337/modules/contract_abis.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

/// uses alchemy token api
/// if want to use another api, you have to create a custom class
class Tokens {
  final BaseProvider _provider;

  Tokens(this._provider);

  String encodeERC20ApproveCall(
    EthereumAddress tokenAddress,
    EthereumAddress spender,
    EtherAmount amount,
  ) {
    return bytesToHex(
        Contract.encodeFunctionCall(
          'approve',
          tokenAddress,
          ContractAbis.get('ERC20'),
          [tokenAddress.hex, spender.hex, amount.getInWei],
        ),
        include0x: true,
        padToEvenLength: true);
  }

  String encodeERC20TransferCall(
    EthereumAddress tokenAddress,
    EthereumAddress recipient,
    EtherAmount amount,
  ) {
    return bytesToHex(
        Contract.encodeFunctionCall(
          'transfer',
          tokenAddress,
          ContractAbis.get('ERC20'),
          [tokenAddress.hex, recipient.hex, amount.getInWei],
        ),
        include0x: true,
        padToEvenLength: true);
  }

  Future<BigInt> getTokenAllowances(EthereumAddress contractAddress,
      EthereumAddress owner, EthereumAddress spender) {
    Map<String, dynamic> params = {
      'contractAddress': contractAddress.hex,
      'owner': owner.hex,
      'spender': spender.hex
    };
    return _provider
        .send<String>('alchemy_getTokenAllowance', [params]).then(BigInt.parse);
  }

  Future<List<Erc20Balance>> getTokenBalances(EthereumAddress address,
      {List<String>? allowedContracts, int? pageKey, int? maxCount}) async {
    Map<String, dynamic> params = {
      'pageKey': pageKey,
      'maxCount': maxCount ?? 100
    };
    List call = [
      address.hex,
      allowedContracts ?? 'erc20',
      pageKey != null ? params : {}
    ];
    final balances = await _provider.send<Map<String, dynamic>>(
        'alchemy_getTokenBalances', call);
    require(balances['address'] == address.hex,
        "Get Balance: Malformed response, try again");

    return Erc20Balance.fromTokenMap(balances['tokenBalances']);
  }

  Future<Erc20TokenMetadata> getTokenMetadata(EthereumAddress contractAddress) {
    return _provider.send<Map<String, dynamic>>('alchemy_getTokenMetadata',
        [contractAddress.hex]).then(Erc20TokenMetadata.fromMap);
  }
}
