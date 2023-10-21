import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart'; // Import your project's dependencies

class InvalidParamException implements Exception {
  final String message;
  InvalidParamException(this.message);

  @override
  String toString() => message;
}

// Create a mock class for BaseProvider
class MockBaseProvider extends Mock implements BaseProvider {}

void main() {
  group('Contract Tests', () {
    late MockBaseProvider mockProvider;
    late Contract contract;
    final contractAddress =
        EthereumAddress.fromHex('0xe785E82358879F061BC3dcAC6f0444462D4b5330');
    final abi = ContractAbi.fromJson(
        '[{"inputs":[{"internalType":"contract IEntryPoint","name":"anEntryPoint","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[{"internalType":"address","name":"target","type":"address"}],"name":"AddressEmptyCode","type":"error"},{"inputs":[{"internalType":"address","name":"implementation","type":"address"}],"name":"ERC1967InvalidImplementation","type":"error"},{"inputs":[],"name":"ERC1967NonPayable","type":"error"},{"inputs":[],"name":"FailedInnerCall","type":"error"},{"inputs":[],"name":"InvalidInitialization","type":"error"},{"inputs":[],"name":"NotInitializing","type":"error"},{"inputs":[],"name":"UUPSUnauthorizedCallContext","type":"error"},{"inputs":[{"internalType":"bytes32","name":"slot","type":"bytes32"}],"name":"UUPSUnsupportedProxiableUUID","type":"error"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint64","name":"version","type":"uint64"}],"name":"Initialized","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"contract IEntryPoint","name":"entryPoint","type":"address"},{"indexed":true,"internalType":"bytes32","name":"credentialHex","type":"bytes32"}],"name":"SimpleAccountInitialized","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"implementation","type":"address"}],"name":"Upgraded","type":"event"},{"inputs":[],"name":"UPGRADE_INTERFACE_VERSION","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"addDeposit","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"credentialHex","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"entryPoint","outputs":[{"internalType":"contract IEntryPoint","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"dest","type":"address"},{"internalType":"uint256","name":"value","type":"uint256"},{"internalType":"bytes","name":"func","type":"bytes"}],"name":"execute","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address[]","name":"dest","type":"address[]"},{"internalType":"uint256[]","name":"value","type":"uint256[]"},{"internalType":"bytes[]","name":"func","type":"bytes[]"}],"name":"executeBatch","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"getCredentialIdBase64","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getDeposit","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getNonce","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"aCredentialHex","type":"bytes32"},{"internalType":"uint256","name":"x","type":"uint256"},{"internalType":"uint256","name":"y","type":"uint256"}],"name":"initialize","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"address","name":"","type":"address"},{"internalType":"uint256[]","name":"","type":"uint256[]"},{"internalType":"uint256[]","name":"","type":"uint256[]"},{"internalType":"bytes","name":"","type":"bytes"}],"name":"onERC1155BatchReceived","outputs":[{"internalType":"bytes4","name":"","type":"bytes4"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"address","name":"","type":"address"},{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"bytes","name":"","type":"bytes"}],"name":"onERC1155Received","outputs":[{"internalType":"bytes4","name":"","type":"bytes4"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"address","name":"","type":"address"},{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"bytes","name":"","type":"bytes"}],"name":"onERC721Received","outputs":[{"internalType":"bytes4","name":"","type":"bytes4"}],"stateMutability":"pure","type":"function"},{"inputs":[],"name":"proxiableUUID","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"publicKey","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes4","name":"interfaceId","type":"bytes4"}],"name":"supportsInterface","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"address","name":"","type":"address"},{"internalType":"address","name":"","type":"address"},{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"bytes","name":"","type":"bytes"},{"internalType":"bytes","name":"","type":"bytes"}],"name":"tokensReceived","outputs":[],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"address","name":"newImplementation","type":"address"},{"internalType":"bytes","name":"data","type":"bytes"}],"name":"upgradeToAndCall","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"components":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"uint256","name":"nonce","type":"uint256"},{"internalType":"bytes","name":"initCode","type":"bytes"},{"internalType":"bytes","name":"callData","type":"bytes"},{"internalType":"uint256","name":"callGasLimit","type":"uint256"},{"internalType":"uint256","name":"verificationGasLimit","type":"uint256"},{"internalType":"uint256","name":"preVerificationGas","type":"uint256"},{"internalType":"uint256","name":"maxFeePerGas","type":"uint256"},{"internalType":"uint256","name":"maxPriorityFeePerGas","type":"uint256"},{"internalType":"bytes","name":"paymasterAndData","type":"bytes"},{"internalType":"bytes","name":"signature","type":"bytes"}],"internalType":"struct UserOperation","name":"userOp","type":"tuple"},{"internalType":"bytes32","name":"userOpHash","type":"bytes32"},{"internalType":"uint256","name":"missingAccountFunds","type":"uint256"}],"name":"validateUserOp","outputs":[{"internalType":"uint256","name":"validationData","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address payable","name":"withdrawAddress","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"withdrawDepositTo","outputs":[],"stateMutability":"nonpayable","type":"function"},{"stateMutability":"payable","type":"receive"}]',
        'SimplePasskeyAccount');

    setUp(() {
      mockProvider = MockBaseProvider();
      contract = Contract(mockProvider);
    });

    test('call returns decoded values', () async {
      const methodName = 'yourMethod';
      final params = [123, 'hello'];

      // Mock the 'eth_call' call on the provider
      when(mockProvider.send<String>('eth_call', any)).thenAnswer(
          (_) async => '0xEncodedResponse'); // Adjust the response as needed

      final decodedValues = await contract.call(
        contractAddress,
        abi,
        methodName,
        params: params,
      );

      // Verify that the decodedValues are as expected
      expect(decodedValues, equals([1, 2, 3])); // Adjust the expected values
    });

    test('getBalance returns EtherAmount', () async {
      final expectedBalance = EtherAmount.inWei(
          BigInt.from(1)); // Adjust the expected value as needed

      // Mock the 'eth_getBalance' call on the provider
      when(mockProvider.send<String>('eth_getBalance', [contractAddress.hex]))
          .thenAnswer((_) async =>
              '0x${BigInt.from(1).toRadixString(16)}'); // 1 Ether in Wei

      final balance = await contract.getBalance(contractAddress);

      expect(balance, equals(expectedBalance));
    });

    test('deployed returns true if contract is deployed', () async {
      // Mock the 'eth_getCode' call on the provider
      when(mockProvider
          .send<String>(
              'eth_getCode', [contractAddress.hex])).thenReturn(Future.value(
          "0x11443c760977081fa9e927b08cab268f6e6783621f2a40102d8cc586e6dee3bc")); // Some bytecode

      final isDeployed = await contract.deployed(contractAddress);

      expect(isDeployed, isTrue);
    });

    test('encodeFunctionCall encodes call correctly', () {
      const methodName = 'initialize';
      final params = [
        hexToBytes(
            '0x11443c760977081fa9e927b08cab268f6e6783621f2a40102d8cc586e6dee3bc'),
        BigInt.parse(
            '0xf5dee907a9f28e50eab51b699ff6becf2783fa5f6cf0d83186e6c8a29f84e7a6'),
        BigInt.parse(
            '0x6e5794995bfe01a6166731db5de6caf5a9cf232364cb816ac6626d46abf8d759')
      ];

      final encodedCall = Contract.encodeFunctionCall(
        methodName,
        contractAddress,
        abi,
        params,
      );

      final expected = hexToBytes(
          "0xf0fd7f6411443c760977081fa9e927b08cab268f6e6783621f2a40102d8cc586e6dee3bcf5dee907a9f28e50eab51b699ff6becf2783fa5f6cf0d83186e6c8a29f84e7a66e5794995bfe01a6166731db5de6caf5a9cf232364cb816ac6626d46abf8d759");

      expect(encodedCall, equals(expected));
    });

    test('encodeFunctionalCall throws on invalid param for abi method', () {
      const methodName = 'initialize';
      List<dynamic> fakeParams = [
        '0x11443c760977081fa9e927b08cab268f6e6783621f2a40102d8cc586e6dee3bc',
        BigInt.parse(
            '0xf5dee907a9f28e50eab51b699ff6becf2783fa5f6cf0d83186e6c8a29f84e7a6'),
        BigInt.parse(
            '0x6e5794995bfe01a6166731db5de6caf5a9cf232364cb816ac6626d46abf8d759')
      ];

      throwFunc() => Contract.encodeFunctionCall(
            methodName,
            contractAddress,
            abi,
            fakeParams,
          );
      expect(throwFunc, throwsA(isA<TypeError>()));

      fakeParams = [
        hexToBytes(
            '0x11443c760977081fa9e927b08cab268f6e6783621f2a40102d8cc586e6dee3bc'),
        BigInt.parse(
            '0xf5dee907a9f28e50eab51b699ff6becf2783fa5f6cf0d83186e6c8a29f84e7a6'),
      ];

      expect(throwFunc, throwsA(isA<ArgumentError>()));
    });

    test('getContractFunction returns a valid contract function', () {
      const methodName = 'initialize';
      final contractFunction = Contract.getContractFunction(
        methodName,
        contractAddress,
        abi,
      );

      expect(contractFunction, isNotNull);
      expect(contractFunction.name, equals(methodName));
    });
  });
}
