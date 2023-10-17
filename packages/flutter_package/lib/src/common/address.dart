import 'package:ens_dart/ens_dart.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

///[Address] extends EthereumAddress with ENS address resolution
class Address extends EthereumAddress {
  String _ens = "";
  final String _baseRpc = 'https://rpc.ankr.com/eth';

  Address(super.addressBytes, {String? ethRpc, bool ens = false}) {
    ens ? _setEnsName(ethRpc ?? _baseRpc) : null;
  }

  factory Address.fromEthAddress(EthereumAddress ethAddress,
      {String? ethRpc, bool ens = false}) {
    return Address(ethAddress.addressBytes, ethRpc: ethRpc, ens: ens);
  }

  static Future<Address> fromEns(String name, {String? ethRpc}) {
    final ens = Ens(
        client:
            Web3Client(ethRpc ?? 'https://rpc.ankr.com/eth', http.Client()));
    return ens.withName(name).getAddress().then((address) {
      return Address(address.addressBytes, ethRpc: ethRpc, ens: true);
    });
  }

  String get ens => _ens;

  /// [avatarUrl] returns the avatar url of the address
  String avatarUrl() {
    return 'https://effigy.im/a/$hex.svg';
  }

  /// [diceAvatar] returns the dice avatar of the address
  String diceAvatar() {
    return 'https://avatars.dicebear.com/api/pixel-art/$hex.svg';
  }

  /// [formattedAddress] formats the address
  String formattedAddress({int length = 6}) {
    final prefix = hex.substring(0, 2 + length);
    final suffix = hex.substring(hex.length - length);
    return '$prefix...$suffix';
  }

  /// [getEnsName] gets the name tied to an address
  /// - @param [ethRpc] is the base rpc url
  /// - returns the name as [String] additionally sets the [_ens]
  Future<String> getEnsName({String? ethRpc}) async {
    return _ens.isEmpty ? await _setEnsName(ethRpc ?? _baseRpc) : _ens;
  }

  /// toEthAddress returns an [EthereumAddress]
  EthereumAddress toEthAddress() {
    return EthereumAddress(addressBytes);
  }

  /// [_setEnsName] sets an address and fetches name from [Ens]
  /// - @param [ethRpc] is the base rpc url
  /// - returns the name as [String]
  Future<String> _setEnsName(String ethRpc) async {
    return _getEnsName(hexEip55).then((name) {
      _ens = name;
      return name;
    }).catchError((err) {
      return "";
    });
  }

  Future<String> _getEnsName(String address, {String? ethRpc}) {
    final ens = Ens(client: Web3Client(ethRpc ?? _baseRpc, http.Client()));
    return ens.withAddress(address).getName();
  }
}
