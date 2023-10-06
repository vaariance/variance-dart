import 'package:ens_dart/ens_dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

import 'mocks/address_test.mocks.dart';
// import 'mocks/basic_address.mock.dart';
// import 'mocks/basic_ens.mock.dart';

final ethAddress =
    EthereumAddress.fromHex('0x95222290dd7278aa3ddd389cc1e1d165cc4bafe5');

late dynamic mockAddress;
late dynamic mockClient;
late dynamic mockEns;

@GenerateMocks([Address, Ens, http.Client])
void main() {
  setUp(() {
    // Instantiating Mocks
    mockAddress = MockAddress();
    mockClient = MockClient();
    mockEns = MockEns();

    Future<String> getName() async {
      return "test.eth";
    }

    // Creating Stubs
    when(mockAddress.getEnsName()).thenAnswer((_) async => getName());

    // Bad input
    when(mockAddress.getEnsName({})).thenAnswer((_) async => "");

    // when(mockEns.withAddress({}).getName()).thenAnswer((_) async => "test.eth");
  });

  group('Address', () {
    test('can be created from an Ethereum address', () {
      final address = Address.fromEthAddress(ethAddress);
      expect(address.addressBytes, equals(ethAddress.addressBytes));
    });

    test('has a getter for the ENS name', () {
      final address = Address.fromEthAddress(ethAddress);
      expect(address.ens, isEmpty);
    });

    test('can get the ENS name asynchronously', () async {
      expect(await mockAddress.getEnsName(), equals('test.eth'));
    });

    test('returns an empty string if the ENS name cannot be resolved',
        () async {
      expect(await mockAddress.getEnsName({}), equals(''));
    });

    test('has a getter for the avatar URL', () {
      final address = Address.fromEthAddress(ethAddress);
      expect(
          address.avatarUrl(),
          equals(
              'https://effigy.im/a/0x95222290dd7278aa3ddd389cc1e1d165cc4bafe5.svg'));
    });

    test('has a getter for the Dice avatar URL', () {
      final address = Address.fromEthAddress(ethAddress);
      expect(
          address.diceAvatar(),
          equals(
              'https://avatars.dicebear.com/api/pixel-art/0x95222290dd7278aa3ddd389cc1e1d165cc4bafe5.svg'));
    });

    test('has a method to format the address', () {
      final address = Address.fromEthAddress(ethAddress);
      expect(address.formattedAddress(), equals('0x952222...4bafe5'));
      expect(
          address.formattedAddress(length: 8), equals('0x95222290...cc4bafe5'));
    });

    test('can be converted to an Ethereum address', () {
      final address = Address.fromEthAddress(ethAddress);
      expect(ethAddress.addressBytes, equals(address.addressBytes));
    });
  });
}
