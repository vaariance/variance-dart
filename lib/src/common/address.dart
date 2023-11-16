part of 'common.dart';

class Address extends ENSResolver {
  Address(super.addressBytes, {super.ens});

  factory Address.fromEthAddress(EthereumAddress ethAddress) {
    return Address(ethAddress.addressBytes);
  }

  static Future<Address> fromEns(String name, {String? ethRpc}) {
    return ENSResolver.fromEns(name, ethRpc: ethRpc)
        .then((value) => Address(value.addressBytes));
  }
}

class AddressFormatter extends EthereumAddress {
  AddressFormatter(super.addressBytes);

  factory AddressFormatter.fromEthAddress(EthereumAddress ethAddress) {
    return AddressFormatter(ethAddress.addressBytes);
  }

  String avatarUrl() {
    return 'https://effigy.im/a/$hex.svg';
  }

  String diceAvatar() {
    return "https://api.dicebear.com/7.x/pixel-art/svg";
  }

  String formattedAddress({int length = 6}) {
    final prefix = hex.substring(0, 2 + length);
    final suffix = hex.substring(hex.length - length);
    return '$prefix...$suffix';
  }

  EthereumAddress toEthAddress() {
    return EthereumAddress(addressBytes);
  }
}

class ENSResolver extends AddressFormatter implements ENSResolverBase {
  String? _ens;

  final String _defaultRpc = 'https://rpc.ankr.com/eth';
  ENSResolver(super.addressBytes, {bool ens = false}) {
    _setEnsName(_defaultRpc);
  }
  
  @override
  String? get ens => _ens;

  @override
  Future<String> getEnsName({String? ethRpc}) async {
    return _ens ?? await _getEnsName(hexEip55, ethRpc: ethRpc);
  }

  @override
  Future<String> getEnsNameForAddress(String address, {String? ethRpc}) {
    return _getEnsName(address, ethRpc: ethRpc);
  }

  Future<String> _getEnsName(String address, {String? ethRpc}) {
    final ens = Ens(client: Web3Client(ethRpc ?? _defaultRpc, http.Client()));
    return ens.withAddress(address).getName();
  }

  Future<void> _setEnsName(String ethRpc) async {
    _getEnsName(hexEip55).then((name) {
      _ens = name;
    }).catchError((err) {
      _ens = null;
    });
  }

  /// Creates an instance of ENSResolver from an ENS name.
  ///
  /// - [name]: The ENS name.
  /// - [ethRpc]: The Ethereum RPC endpoint URL (optional).
  ///
  /// Returns a [Future] that completes with an instance of ENSResolver.
  static Future<ENSResolver> fromEns(String name, {String? ethRpc}) {
    final ens = Ens(
        client:
            Web3Client(ethRpc ?? 'https://rpc.ankr.com/eth', http.Client()));
    return ens
        .withName(name)
        .getAddress()
        .then((address) => ENSResolver(address.addressBytes));
  }
}
