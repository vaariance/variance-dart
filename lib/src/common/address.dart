part of 'common.dart';

class Address extends EthereumAddress implements ENSResolverBase {
  String? _ens;

  ChainBaseApiBase? client;

  Address(super.addressBytes, {bool ens = false, this.client}) {
    _setEnsName();
  }

  factory Address.fromEthAddress(EthereumAddress ethAddress) {
    return Address(ethAddress.addressBytes);
  }

  @override
  String? get ens => _ens;

  @override
  Future<String?>? getEnsName() async {
    return _ens ?? await _getEnsName(this);
  }

  @override
  Future<String?>? getEnsNameForAddress(EthereumAddress address) {
    return _getEnsName(address);
  }

  @override
  Address withClient(ChainBaseApiBase client) {
    return Address(addressBytes, client: client);
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

  /// Creates an instance of Address from an ENS name.
  ///
  /// - [name]: The ENS name.
  ///
  /// Returns a [Future] that completes with an instance of Address.
  static Future<Address?>? fromEns(String name, {ChainBaseApiBase? client}) {
    return client
        ?.resolveENSName(name)
        .then((value) => value.data?.address)
        .then((address) => address == null
            ? null
            : Address(EthereumAddress.fromHex(address).addressBytes));
  }
}

extension AddressExtension on EthereumAddress {
  String avatarUrl() {
    return 'https://effigy.im/a/$hex.svg';
  }

  String formattedAddress({int length = 6}) {
    final prefix = hex.substring(0, 2 + length);
    final suffix = hex.substring(hex.length - length);
    return '$prefix...$suffix';
  }
}
