import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/4337/modules/contract.dart';
import 'package:pks_4337_sdk/src/abi/abis.dart';
import 'package:web3dart/web3dart.dart'; // Import your project's dependencies

// Create a mock class for BaseProvider
class MockBaseProvider extends Mock implements BaseProvider {}

void main() {
  group('Contract Tests', () {
    late MockBaseProvider mockProvider;
    late Contract contract;
    final contractAddress =
        EthereumAddress.fromHex('0x95222290dd7278aa3ddd389cc1e1d165cc4bafe5');
    final abi = ContractAbis.get('ERC20');
    setUp(() {
      mockProvider = MockBaseProvider();
      contract = Contract(mockProvider);
    });

    test('getBalance returns EtherAmount', () async {
      final expectedBalance = EtherAmount.fromInt(
          EtherUnit.wei, 1); // Adjust the expected value as needed

      // Mock the 'eth_getBalance' call on the provider
      when(mockProvider.send<String>('eth_getBalance', [contractAddress.hex]))
          .thenAnswer((_) async => '1000000000000000000'); // 1 Ether in Wei

      final balance = await contract.getBalance(contractAddress);

      expect(balance, equals(expectedBalance));
    });

    test('deployed returns true if contract is deployed', () async {
      // Mock the 'eth_getCode' call on the provider
      when(mockProvider.send<String>('eth_getCode', [contractAddress.hex]))
          .thenAnswer(
              (_) async => ''); // Empty response indicates contract deployment

      final isDeployed = await contract.deployed(contractAddress);

      expect(isDeployed, isTrue);
    });

    // Add more tests for other methods of the Contract class as needed.
  });
}
