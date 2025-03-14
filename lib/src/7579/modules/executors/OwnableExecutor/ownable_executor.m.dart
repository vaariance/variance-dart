// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated from lib/src/7579/modules/executors/OwnableExecutor/ownable_executor.abi.json

import 'package:web3dart/web3dart.dart';

/// The ABI string exported from the original .abi.json file.
final ContractAbi ownable_executor_abi = ContractAbi.fromJson('[{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"addOwner","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"ownedAccount","type":"address"},{"internalType":"bytes","name":"callData","type":"bytes"}],"name":"executeBatchOnOwnedAccount","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"ownedAccount","type":"address"},{"internalType":"bytes","name":"callData","type":"bytes"}],"name":"executeOnOwnedAccount","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"getOwners","outputs":[{"internalType":"address[]","name":"ownersArray","type":"address[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"ownerCount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"prevOwner","type":"address"},{"internalType":"address","name":"owner","type":"address"}],"name":"removeOwner","outputs":[],"stateMutability":"nonpayable","type":"function"}]', 'ownable_executor');

/// A helper class for the contract.
/// You must provide the contract [address] when instantiating.
class OwnableExecutorContract {
  final DeployedContract contract;

  OwnableExecutorContract(EthereumAddress address)
      : contract = DeployedContract(ownable_executor_abi, address);
}
