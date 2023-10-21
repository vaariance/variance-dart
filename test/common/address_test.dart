import 'package:ens_dart/ens_dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

import 'mocks/address_test.mocks.dart';

final ethAddress =
    EthereumAddress.fromHex('0x95222290dd7278aa3ddd389cc1e1d165cc4bafe5');

@GenerateMocks([Ens, Web3Client, http.Client])
void main() {
  group('Address', () {
    final mockEns = MockEns();
    final mockWeb3Client = MockWeb3Client();
    final mockHttpClient = MockClient();

    test('can be created from an Ethereum address', () {
      final address = Address.fromEthAddress(ethAddress);
      expect(address.addressBytes, equals(ethAddress.addressBytes));
    });

    test('has a getter for the ENS name', () {
      final address = Address.fromEthAddress(ethAddress);
      expect(address.ens, isEmpty);
    });

    test('can get the ENS name asynchronously', () async {
      Future<String> getName() {
        return Future.value("test.eth");
      }

      when(mockEns.withAddress(()).getName()).thenAnswer((_) => getName());

      Address address = Address.fromEthAddress(
          EthereumAddress.fromHex('0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5'),
          ens: true);

      expect(await address.getEnsName(), equals('test.eth'));

      // Verify the interaction with the mock Ens
      verify(() => mockEns.withAddress(()).getName()).called(1);
    });

    test('returns an empty string if the ENS name cannot be resolved',
        () async {});

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
