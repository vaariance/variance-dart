part of 'common.dart';

class Address extends ENSResolver {
  Address(super.addressBytes, {super.ens});

  factory Address.fromEthAddress(EthereumAddress ethAddress) {
    return Address(ethAddress.addressBytes);
  }

  static Future<Address?>? fromEns(String name, {ChainBaseApiBase? client}) {
    return ENSResolver.fromEns(name, client: client)
        ?.then((value) => value == null ? null : Address(value.addressBytes));
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

  ChainBaseApiBase? client;

  ENSResolver(super.addressBytes, {bool ens = false, this.client}) {
    _setEnsName();
  }

  @override
  String? get ens => _ens;

  @override
  ENSResolverBase withClient(ChainBaseApiBase client) {
    return ENSResolver(addressBytes, client: client);
  }

  @override
  Future<String?>? getEnsName() async {
    return _ens ?? await _getEnsName(this);
  }

  @override
  Future<String?>? getEnsNameForAddress(EthereumAddress address) {
    return _getEnsName(address);
  }

  Future<String?>? _getEnsName(EthereumAddress address) {
    return client?.reverseENSAddress(address).then((value) => value.data?.name);
  }

  Future<void> _setEnsName() async {
    _getEnsName(this)?.then((name) {
      _ens = name;
    }).catchError((err) {
      _ens = null;
    });
  }

  /// Creates an instance of ENSResolver from an ENS name.
  ///
  /// - [name]: The ENS name.
  ///
  /// Returns a [Future] that completes with an instance of ENSResolver.
  static Future<ENSResolver?>? fromEns(String name,
      {ChainBaseApiBase? client}) {
    return client
        ?.resolveENSName(name)
        .then((value) => value.data?.address)
        .then((address) => address == null
            ? null
            : ENSResolver(EthereumAddress.fromHex(address).addressBytes));
  }
}
