import 'dart:typed_data';

import 'package:ens_dart/ens_dart.dart';
import 'package:web3dart/src/contracts/abi/abi.dart';
import 'package:web3dart/src/contracts/deployed_contract.dart';
import 'package:web3dart/src/core/block_number.dart';
import 'package:web3dart/src/credentials/address.dart';
import 'package:web3dart/src/credentials/credentials.dart';
import 'package:web3dart/web3dart.dart';

class BasicMockENS implements Ens {
  // Mock mapping of addresses to ENS names
  final Map<String, String> _addressToENS = {};

  // Function to register a new ENS name for an address
  void registerENS(String address, String ensName) {
    _addressToENS[address.toLowerCase()] = ensName;
  }

  @override
  Stream<ABIChanged> aBIChangedEvents(
      {BlockNum? fromBlock, BlockNum? toBlock}) {
    // TODO: implement aBIChangedEvents
    throw UnimplementedError();
  }

  @override
  Future<ABI> abi(Uint8List node, BigInt contentTypes, {BlockNum? atBlock}) {
    // TODO: implement abi
    throw UnimplementedError();
  }

  @override
  Future<EthereumAddress> addr(Uint8List node, {BlockNum? atBlock}) {
    // TODO: implement addr
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> addr$2(Uint8List node, BigInt coinType,
      {BlockNum? atBlock}) {
    // TODO: implement addr$2
    throw UnimplementedError();
  }

  @override
  Stream<AddrChanged> addrChangedEvents(
      {BlockNum? fromBlock, BlockNum? toBlock}) {
    // TODO: implement addrChangedEvents
    throw UnimplementedError();
  }

  @override
  Stream<AddressChanged> addressChangedEvents(
      {BlockNum? fromBlock, BlockNum? toBlock}) {
    // TODO: implement addressChangedEvents
    throw UnimplementedError();
  }

  @override
  Stream<AuthorisationChanged> authorisationChangedEvents(
      {BlockNum? fromBlock, BlockNum? toBlock}) {
    // TODO: implement authorisationChangedEvents
    throw UnimplementedError();
  }

  @override
  Future<bool> authorisations(
      Uint8List $param5, EthereumAddress $param6, EthereumAddress $param7,
      {BlockNum? atBlock}) {
    // TODO: implement authorisations
    throw UnimplementedError();
  }

  @override
  // TODO: implement chainId
  int? get chainId => throw UnimplementedError();

  @override
  bool checkSignature(ContractFunction function, String expected) {
    // TODO: implement checkSignature
    throw UnimplementedError();
  }

  @override
  Future<String> clearDNSZone(Uint8List node,
      {required Credentials credentials, Transaction? transaction}) {
    // TODO: implement clearDNSZone
    throw UnimplementedError();
  }

  @override
  // TODO: implement client
  Web3Client get client => throw UnimplementedError();

  @override
  Future<Uint8List> contenthash(Uint8List node, {BlockNum? atBlock}) {
    // TODO: implement contenthash
    throw UnimplementedError();
  }

  @override
  Stream<ContenthashChanged> contenthashChangedEvents(
      {BlockNum? fromBlock, BlockNum? toBlock}) {
    // TODO: implement contenthashChangedEvents
    throw UnimplementedError();
  }

  @override
  Stream<DNSRecordChanged> dNSRecordChangedEvents(
      {BlockNum? fromBlock, BlockNum? toBlock}) {
    // TODO: implement dNSRecordChangedEvents
    throw UnimplementedError();
  }

  @override
  Stream<DNSRecordDeleted> dNSRecordDeletedEvents(
      {BlockNum? fromBlock, BlockNum? toBlock}) {
    // TODO: implement dNSRecordDeletedEvents
    throw UnimplementedError();
  }

  @override
  Stream<DNSZoneCleared> dNSZoneClearedEvents(
      {BlockNum? fromBlock, BlockNum? toBlock}) {
    // TODO: implement dNSZoneClearedEvents
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> dnsRecord(Uint8List node, Uint8List name, BigInt resource,
      {BlockNum? atBlock}) {
    // TODO: implement dnsRecord
    throw UnimplementedError();
  }

  @override
  // TODO: implement ensAddress
  EthereumAddress? get ensAddress => throw UnimplementedError();

  @override
  // TODO: implement ensName
  String? get ensName => throw UnimplementedError();

  @override
  Future<bool> hasDNSRecords(Uint8List node, Uint8List name,
      {BlockNum? atBlock}) {
    // TODO: implement hasDNSRecords
    throw UnimplementedError();
  }

  @override
  Stream<InterfaceChanged> interfaceChangedEvents(
      {BlockNum? fromBlock, BlockNum? toBlock}) {
    // TODO: implement interfaceChangedEvents
    throw UnimplementedError();
  }

  @override
  Future<EthereumAddress> interfaceImplementer(
      Uint8List node, Uint8List interfaceID,
      {BlockNum? atBlock}) {
    // TODO: implement interfaceImplementer
    throw UnimplementedError();
  }

  @override
  Future<String> name(Uint8List node, {BlockNum? atBlock}) {
    // TODO: implement name
    throw UnimplementedError();
  }

  @override
  Stream<NameChanged> nameChangedEvents(
      {BlockNum? fromBlock, BlockNum? toBlock}) {
    // TODO: implement nameChangedEvents
    throw UnimplementedError();
  }

  @override
  Future<Pubkey> pubkey(Uint8List node, {BlockNum? atBlock}) {
    // TODO: implement pubkey
    throw UnimplementedError();
  }

  @override
  Stream<PubkeyChanged> pubkeyChangedEvents(
      {BlockNum? fromBlock, BlockNum? toBlock}) {
    // TODO: implement pubkeyChangedEvents
    throw UnimplementedError();
  }

  @override
  Future<List> read(ContractFunction function, List params, BlockNum? atBlock) {
    // TODO: implement read
    throw UnimplementedError();
  }

  @override
  Ens reverseEns(EthereumAddress addr) {
    // TODO: implement reverseEns
    throw UnimplementedError();
  }

  @override
  // TODO: implement self
  DeployedContract get self => throw UnimplementedError();

  @override
  Future<String> setABI(Uint8List node, BigInt contentType, Uint8List data,
      {required Credentials credentials, Transaction? transaction}) {
    // TODO: implement setABI
    throw UnimplementedError();
  }

  @override
  Future<String> setAddr(Uint8List node, BigInt coinType, Uint8List a,
      {required Credentials credentials, Transaction? transaction}) {
    // TODO: implement setAddr
    throw UnimplementedError();
  }

  @override
  Future<String> setAddr$2(Uint8List node, EthereumAddress a,
      {required Credentials credentials, Transaction? transaction}) {
    // TODO: implement setAddr$2
    throw UnimplementedError();
  }

  @override
  Future<String> setAuthorisation(
      Uint8List node, EthereumAddress target, bool isAuthorised,
      {required Credentials credentials, Transaction? transaction}) {
    // TODO: implement setAuthorisation
    throw UnimplementedError();
  }

  @override
  Future<String> setContenthash(Uint8List node, Uint8List hash,
      {required Credentials credentials, Transaction? transaction}) {
    // TODO: implement setContenthash
    throw UnimplementedError();
  }

  @override
  Future<String> setDNSRecords(Uint8List node, Uint8List data,
      {required Credentials credentials, Transaction? transaction}) {
    // TODO: implement setDNSRecords
    throw UnimplementedError();
  }

  @override
  void setEnsTextRecord(EnsTextRecord? _) {
    // TODO: implement setEnsTextRecord
  }

  @override
  Future<String> setInterface(
      Uint8List node, Uint8List interfaceID, EthereumAddress implementer,
      {required Credentials credentials, Transaction? transaction}) {
    // TODO: implement setInterface
    throw UnimplementedError();
  }

  @override
  Future<String> setName(Uint8List node, String name,
      {required Credentials credentials, Transaction? transaction}) {
    // TODO: implement setName
    throw UnimplementedError();
  }

  @override
  Future<String> setPubkey(Uint8List node, Uint8List x, Uint8List y,
      {required Credentials credentials, Transaction? transaction}) {
    // TODO: implement setPubkey
    throw UnimplementedError();
  }

  @override
  Future<String> setText(Uint8List node, String key, String value,
      {required Credentials credentials, Transaction? transaction}) {
    // TODO: implement setText
    throw UnimplementedError();
  }

  @override
  Future<bool> supportsInterface(Uint8List interfaceID, {BlockNum? atBlock}) {
    // TODO: implement supportsInterface
    throw UnimplementedError();
  }

  @override
  Future<String> text(Uint8List node, String key, {BlockNum? atBlock}) {
    // TODO: implement text
    throw UnimplementedError();
  }

  @override
  Stream<TextChanged> textChangedEvents(
      {BlockNum? fromBlock, BlockNum? toBlock}) {
    // TODO: implement textChangedEvents
    throw UnimplementedError();
  }

  @override
  // TODO: implement textRecord
  EnsTextRecord? get textRecord => throw UnimplementedError();

  // Simon: Only thing needed for this mock
  @override
  Ens withAddress(Object? _) {
    return this;
  }

  @override
  Ens withName(String? _name) {
    // TODO: implement withName
    throw UnimplementedError();
  }

  @override
  Future<String> write(Credentials credentials, Transaction? base,
      ContractFunction function, List parameters) {
    throw UnimplementedError();
  }
}
