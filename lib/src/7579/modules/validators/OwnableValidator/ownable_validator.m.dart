// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated from lib/src/7579/modules/validators/OwnableValidator/ownable_validator.abi.json

import 'package:web3dart/web3dart.dart';

/// The ABI string exported from the original .abi.json file.
final ContractAbi ownable_validator_abi = ContractAbi.fromJson('[{"inputs":[{"internalType":"bytes32","name":"hash","type":"bytes32"},{"internalType":"bytes","name":"signature","type":"bytes"},{"internalType":"bytes","name":"data","type":"bytes"}],"name":"validateSignatureWithData","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"addOwner","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"getOwners","outputs":[{"internalType":"address[]","name":"ownersArray","type":"address[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"ownerCount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"prevOwner","type":"address"},{"internalType":"address","name":"owner","type":"address"}],"name":"removeOwner","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"_threshold","type":"uint256"}],"name":"setThreshold","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"threshold","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]', 'ownable_validator');

/// A helper class for the contract.
/// You must provide the contract [address] when instantiating.
class OwnableValidatorContract {
  final DeployedContract contract;

  OwnableValidatorContract(EthereumAddress address)
      : contract = DeployedContract(ownable_validator_abi, address);
}
