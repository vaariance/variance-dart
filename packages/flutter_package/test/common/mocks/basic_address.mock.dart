import 'dart:typed_data';

import 'package:pks_4337_sdk/src/common/address.dart';
import 'package:web3dart/web3dart.dart';

import 'basic_ens.mock.dart';

class MockAddress implements Address {
  String _ens = "";
  final String _baseRpc = 'https://dummy.rpc';

  @override
  // TODO: implement addressBytes
  Uint8List get addressBytes => throw UnimplementedError();

  get http => null;

  @override
  String avatarUrl() {
    // TODO: implement avatarUrl
    throw UnimplementedError();
  }

  @override
  int compareTo(EthereumAddress other) {
    // TODO: implement compareTo
    throw UnimplementedError();
  }

  @override
  String diceAvatar() {
    // TODO: implement diceAvatar
    throw UnimplementedError();
  }

  @override
  // TODO: implement ens

  String get ens => _ens;

  @override
  String formattedAddress({int length = 6}) {
    // TODO: implement formattedAddress
    throw UnimplementedError();
  }

  @override
  Future<String> getEnsName({String? ethRpc}) async {
    return _ens.isEmpty ? await _setEnsName(ethRpc ?? _baseRpc) : _ens;
  }

  @override
  // TODO: implement hex
  String get hex => throw UnimplementedError();

  @override
  // TODO: implement hexEip55
  String get hexEip55 => throw UnimplementedError();

  @override
  // TODO: implement hexNo0x
  String get hexNo0x => throw UnimplementedError();

  @override
  EthereumAddress toEthAddress() {
    // TODO: implement toEthAddress
    throw UnimplementedError();
  }

  Future<String> _setEnsName(String ethRpc) {
    final ens = MockENS();

    return ens.withAddress(hexEip55).getName().then((name) {
      _ens = name;
      return name;
    }).catchError((err) {
      return "";
    });
  }
}
