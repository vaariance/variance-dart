import 'dart:developer';

import 'package:ens_dart/ens_dart.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class Address extends EthereumAddress {
  String _ens = "";
  final String _baseRpc = 'https://rpc.ankr.com/eth';

  String get ens => _ens;

  Address(super.addressBytes, {String? ethRpc, bool ens = false}) {
    ens ? _setEnsName(ethRpc ?? _baseRpc) : null;
  }

  Future<String>? _setEnsName(String ethRpc) {
    final ens = Ens(client: Web3Client(ethRpc, http.Client()));
    try {
      return ens.withAddress(hexEip55).getName().then((name) {
        _ens = name;
        return name;
      });
    } catch (e) {
      log("no ens name for $hex");
      return null;
    }
  }

  Future<String> getEnsName({String? ethRpc}) async {
    return _ens.isEmpty ? await _setEnsName(ethRpc ?? _baseRpc) ?? "" : _ens;
  }

  String formattedAddress({int length = 6}) {
    final prefix = hex.substring(0, 2 + hex.length);
    final suffix = hex.substring(hex.length - length);
    return '$prefix...$suffix';
  }

  String avatarUrl() {
    return 'https://effigy.im/a/$hex.svg';
  }

  String diceAvatar() {
    return 'https://avatars.dicebear.com/api/pixel-art/$hex.svg';
  }

  factory Address.fromEthAddress(EthereumAddress ethAddress,
      {String? ethRpc, bool ens = false}) {
    return Address(ethAddress.addressBytes, ethRpc: ethRpc, ens: ens);
  }

  EthereumAddress toEthAddress() {
    return EthereumAddress(addressBytes);
  }
}
