// @dart=3.0
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_local_variable, unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:web3dart/web3dart.dart' as _i1;
import 'dart:typed_data' as _i2;

final _contractAbi = _i1.ContractAbi.fromJson(
  '[{"inputs":[{"internalType":"uint256","name":"preOpGas","type":"uint256"},{"internalType":"uint256","name":"paid","type":"uint256"},{"internalType":"uint48","name":"validAfter","type":"uint48"},{"internalType":"uint48","name":"validUntil","type":"uint48"},{"internalType":"bool","name":"targetSuccess","type":"bool"},{"internalType":"bytes","name":"targetResult","type":"bytes"}],"name":"ExecutionResult","type":"error"},{"inputs":[{"internalType":"uint256","name":"opIndex","type":"uint256"},{"internalType":"string","name":"reason","type":"string"}],"name":"FailedOp","type":"error"},{"inputs":[{"internalType":"address","name":"sender","type":"address"}],"name":"SenderAddressResult","type":"error"},{"inputs":[{"internalType":"address","name":"aggregator","type":"address"}],"name":"SignatureValidationFailed","type":"error"},{"inputs":[{"components":[{"internalType":"uint256","name":"preOpGas","type":"uint256"},{"internalType":"uint256","name":"prefund","type":"uint256"},{"internalType":"bool","name":"sigFailed","type":"bool"},{"internalType":"uint48","name":"validAfter","type":"uint48"},{"internalType":"uint48","name":"validUntil","type":"uint48"},{"internalType":"bytes","name":"paymasterContext","type":"bytes"}],"internalType":"struct IEntryPoint.ReturnInfo","name":"returnInfo","type":"tuple"},{"components":[{"internalType":"uint256","name":"stake","type":"uint256"},{"internalType":"uint256","name":"unstakeDelaySec","type":"uint256"}],"internalType":"struct IStakeManager.StakeInfo","name":"senderInfo","type":"tuple"},{"components":[{"internalType":"uint256","name":"stake","type":"uint256"},{"internalType":"uint256","name":"unstakeDelaySec","type":"uint256"}],"internalType":"struct IStakeManager.StakeInfo","name":"factoryInfo","type":"tuple"},{"components":[{"internalType":"uint256","name":"stake","type":"uint256"},{"internalType":"uint256","name":"unstakeDelaySec","type":"uint256"}],"internalType":"struct IStakeManager.StakeInfo","name":"paymasterInfo","type":"tuple"}],"name":"ValidationResult","type":"error"},{"inputs":[{"components":[{"internalType":"uint256","name":"preOpGas","type":"uint256"},{"internalType":"uint256","name":"prefund","type":"uint256"},{"internalType":"bool","name":"sigFailed","type":"bool"},{"internalType":"uint48","name":"validAfter","type":"uint48"},{"internalType":"uint48","name":"validUntil","type":"uint48"},{"internalType":"bytes","name":"paymasterContext","type":"bytes"}],"internalType":"struct IEntryPoint.ReturnInfo","name":"returnInfo","type":"tuple"},{"components":[{"internalType":"uint256","name":"stake","type":"uint256"},{"internalType":"uint256","name":"unstakeDelaySec","type":"uint256"}],"internalType":"struct IStakeManager.StakeInfo","name":"senderInfo","type":"tuple"},{"components":[{"internalType":"uint256","name":"stake","type":"uint256"},{"internalType":"uint256","name":"unstakeDelaySec","type":"uint256"}],"internalType":"struct IStakeManager.StakeInfo","name":"factoryInfo","type":"tuple"},{"components":[{"internalType":"uint256","name":"stake","type":"uint256"},{"internalType":"uint256","name":"unstakeDelaySec","type":"uint256"}],"internalType":"struct IStakeManager.StakeInfo","name":"paymasterInfo","type":"tuple"},{"components":[{"internalType":"address","name":"aggregator","type":"address"},{"components":[{"internalType":"uint256","name":"stake","type":"uint256"},{"internalType":"uint256","name":"unstakeDelaySec","type":"uint256"}],"internalType":"struct IStakeManager.StakeInfo","name":"stakeInfo","type":"tuple"}],"internalType":"struct IEntryPoint.AggregatorStakeInfo","name":"aggregatorInfo","type":"tuple"}],"name":"ValidationResultWithAggregation","type":"error"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"bytes32","name":"userOpHash","type":"bytes32"},{"indexed":true,"internalType":"address","name":"sender","type":"address"},{"indexed":false,"internalType":"address","name":"factory","type":"address"},{"indexed":false,"internalType":"address","name":"paymaster","type":"address"}],"name":"AccountDeployed","type":"event"},{"anonymous":false,"inputs":[],"name":"BeforeExecution","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"account","type":"address"},{"indexed":false,"internalType":"uint256","name":"totalDeposit","type":"uint256"}],"name":"Deposited","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"aggregator","type":"address"}],"name":"SignatureAggregatorChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"account","type":"address"},{"indexed":false,"internalType":"uint256","name":"totalStaked","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"unstakeDelaySec","type":"uint256"}],"name":"StakeLocked","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"account","type":"address"},{"indexed":false,"internalType":"uint256","name":"withdrawTime","type":"uint256"}],"name":"StakeUnlocked","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"account","type":"address"},{"indexed":false,"internalType":"address","name":"withdrawAddress","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"StakeWithdrawn","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"bytes32","name":"userOpHash","type":"bytes32"},{"indexed":true,"internalType":"address","name":"sender","type":"address"},{"indexed":true,"internalType":"address","name":"paymaster","type":"address"},{"indexed":false,"internalType":"uint256","name":"nonce","type":"uint256"},{"indexed":false,"internalType":"bool","name":"success","type":"bool"},{"indexed":false,"internalType":"uint256","name":"actualGasCost","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"actualGasUsed","type":"uint256"}],"name":"UserOperationEvent","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"bytes32","name":"userOpHash","type":"bytes32"},{"indexed":true,"internalType":"address","name":"sender","type":"address"},{"indexed":false,"internalType":"uint256","name":"nonce","type":"uint256"},{"indexed":false,"internalType":"bytes","name":"revertReason","type":"bytes"}],"name":"UserOperationRevertReason","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"account","type":"address"},{"indexed":false,"internalType":"address","name":"withdrawAddress","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"Withdrawn","type":"event"},{"inputs":[],"name":"SIG_VALIDATION_FAILED","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes","name":"initCode","type":"bytes"},{"internalType":"address","name":"sender","type":"address"},{"internalType":"bytes","name":"paymasterAndData","type":"bytes"}],"name":"_validateSenderAndPaymaster","outputs":[],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint32","name":"unstakeDelaySec","type":"uint32"}],"name":"addStake","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"depositTo","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"deposits","outputs":[{"internalType":"uint112","name":"deposit","type":"uint112"},{"internalType":"bool","name":"staked","type":"bool"},{"internalType":"uint112","name":"stake","type":"uint112"},{"internalType":"uint32","name":"unstakeDelaySec","type":"uint32"},{"internalType":"uint48","name":"withdrawTime","type":"uint48"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"getDepositInfo","outputs":[{"components":[{"internalType":"uint112","name":"deposit","type":"uint112"},{"internalType":"bool","name":"staked","type":"bool"},{"internalType":"uint112","name":"stake","type":"uint112"},{"internalType":"uint32","name":"unstakeDelaySec","type":"uint32"},{"internalType":"uint48","name":"withdrawTime","type":"uint48"}],"internalType":"struct IStakeManager.DepositInfo","name":"info","type":"tuple"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"uint192","name":"key","type":"uint192"}],"name":"getNonce","outputs":[{"internalType":"uint256","name":"nonce","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes","name":"initCode","type":"bytes"}],"name":"getSenderAddress","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"components":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"uint256","name":"nonce","type":"uint256"},{"internalType":"bytes","name":"initCode","type":"bytes"},{"internalType":"bytes","name":"callData","type":"bytes"},{"internalType":"uint256","name":"callGasLimit","type":"uint256"},{"internalType":"uint256","name":"verificationGasLimit","type":"uint256"},{"internalType":"uint256","name":"preVerificationGas","type":"uint256"},{"internalType":"uint256","name":"maxFeePerGas","type":"uint256"},{"internalType":"uint256","name":"maxPriorityFeePerGas","type":"uint256"},{"internalType":"bytes","name":"paymasterAndData","type":"bytes"},{"internalType":"bytes","name":"signature","type":"bytes"}],"internalType":"struct UserOperation","name":"userOp","type":"tuple"}],"name":"getUserOpHash","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[{"components":[{"components":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"uint256","name":"nonce","type":"uint256"},{"internalType":"bytes","name":"initCode","type":"bytes"},{"internalType":"bytes","name":"callData","type":"bytes"},{"internalType":"uint256","name":"callGasLimit","type":"uint256"},{"internalType":"uint256","name":"verificationGasLimit","type":"uint256"},{"internalType":"uint256","name":"preVerificationGas","type":"uint256"},{"internalType":"uint256","name":"maxFeePerGas","type":"uint256"},{"internalType":"uint256","name":"maxPriorityFeePerGas","type":"uint256"},{"internalType":"bytes","name":"paymasterAndData","type":"bytes"},{"internalType":"bytes","name":"signature","type":"bytes"}],"internalType":"struct UserOperation[]","name":"userOps","type":"tuple[]"},{"internalType":"contract IAggregator","name":"aggregator","type":"address"},{"internalType":"bytes","name":"signature","type":"bytes"}],"internalType":"struct IEntryPoint.UserOpsPerAggregator[]","name":"opsPerAggregator","type":"tuple[]"},{"internalType":"address payable","name":"beneficiary","type":"address"}],"name":"handleAggregatedOps","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"components":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"uint256","name":"nonce","type":"uint256"},{"internalType":"bytes","name":"initCode","type":"bytes"},{"internalType":"bytes","name":"callData","type":"bytes"},{"internalType":"uint256","name":"callGasLimit","type":"uint256"},{"internalType":"uint256","name":"verificationGasLimit","type":"uint256"},{"internalType":"uint256","name":"preVerificationGas","type":"uint256"},{"internalType":"uint256","name":"maxFeePerGas","type":"uint256"},{"internalType":"uint256","name":"maxPriorityFeePerGas","type":"uint256"},{"internalType":"bytes","name":"paymasterAndData","type":"bytes"},{"internalType":"bytes","name":"signature","type":"bytes"}],"internalType":"struct UserOperation[]","name":"ops","type":"tuple[]"},{"internalType":"address payable","name":"beneficiary","type":"address"}],"name":"handleOps","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint192","name":"key","type":"uint192"}],"name":"incrementNonce","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes","name":"callData","type":"bytes"},{"components":[{"components":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"uint256","name":"nonce","type":"uint256"},{"internalType":"uint256","name":"callGasLimit","type":"uint256"},{"internalType":"uint256","name":"verificationGasLimit","type":"uint256"},{"internalType":"uint256","name":"preVerificationGas","type":"uint256"},{"internalType":"address","name":"paymaster","type":"address"},{"internalType":"uint256","name":"maxFeePerGas","type":"uint256"},{"internalType":"uint256","name":"maxPriorityFeePerGas","type":"uint256"}],"internalType":"struct EntryPoint.MemoryUserOp","name":"mUserOp","type":"tuple"},{"internalType":"bytes32","name":"userOpHash","type":"bytes32"},{"internalType":"uint256","name":"prefund","type":"uint256"},{"internalType":"uint256","name":"contextOffset","type":"uint256"},{"internalType":"uint256","name":"preOpGas","type":"uint256"}],"internalType":"struct EntryPoint.UserOpInfo","name":"opInfo","type":"tuple"},{"internalType":"bytes","name":"context","type":"bytes"}],"name":"innerHandleOp","outputs":[{"internalType":"uint256","name":"actualGasCost","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"uint192","name":"","type":"uint192"}],"name":"nonceSequenceNumber","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"components":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"uint256","name":"nonce","type":"uint256"},{"internalType":"bytes","name":"initCode","type":"bytes"},{"internalType":"bytes","name":"callData","type":"bytes"},{"internalType":"uint256","name":"callGasLimit","type":"uint256"},{"internalType":"uint256","name":"verificationGasLimit","type":"uint256"},{"internalType":"uint256","name":"preVerificationGas","type":"uint256"},{"internalType":"uint256","name":"maxFeePerGas","type":"uint256"},{"internalType":"uint256","name":"maxPriorityFeePerGas","type":"uint256"},{"internalType":"bytes","name":"paymasterAndData","type":"bytes"},{"internalType":"bytes","name":"signature","type":"bytes"}],"internalType":"struct UserOperation","name":"op","type":"tuple"},{"internalType":"address","name":"target","type":"address"},{"internalType":"bytes","name":"targetCallData","type":"bytes"}],"name":"simulateHandleOp","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"components":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"uint256","name":"nonce","type":"uint256"},{"internalType":"bytes","name":"initCode","type":"bytes"},{"internalType":"bytes","name":"callData","type":"bytes"},{"internalType":"uint256","name":"callGasLimit","type":"uint256"},{"internalType":"uint256","name":"verificationGasLimit","type":"uint256"},{"internalType":"uint256","name":"preVerificationGas","type":"uint256"},{"internalType":"uint256","name":"maxFeePerGas","type":"uint256"},{"internalType":"uint256","name":"maxPriorityFeePerGas","type":"uint256"},{"internalType":"bytes","name":"paymasterAndData","type":"bytes"},{"internalType":"bytes","name":"signature","type":"bytes"}],"internalType":"struct UserOperation","name":"userOp","type":"tuple"}],"name":"simulateValidation","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"unlockStake","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address payable","name":"withdrawAddress","type":"address"}],"name":"withdrawStake","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address payable","name":"withdrawAddress","type":"address"},{"internalType":"uint256","name":"withdrawAmount","type":"uint256"}],"name":"withdrawTo","outputs":[],"stateMutability":"nonpayable","type":"function"},{"stateMutability":"payable","type":"receive"}]',
  'Entrypoint',
);

class Entrypoint extends _i1.GeneratedContract {
  Entrypoint({
    required _i1.EthereumAddress address,
    required _i1.Web3Client client,
    int? chainId,
  }) : super(
          _i1.DeployedContract(
            _contractAbi,
            address,
          ),
          client,
          chainId,
        );

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> SIG_VALIDATION_FAILED({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[0];
    assert(checkSignature(function, '8f41ec5a'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<void> _validateSenderAndPaymaster(
    ({
      _i2.Uint8List initCode,
      _i1.EthereumAddress sender,
      _i2.Uint8List paymasterAndData
    }) args, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[1];
    assert(checkSignature(function, '957122ab'));
    final params = [
      args.initCode,
      args.sender,
      args.paymasterAndData,
    ];
    final response = await read(
      function,
      params,
      atBlock,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> addStake(
    ({BigInt unstakeDelaySec}) args, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[2];
    assert(checkSignature(function, '0396cb60'));
    final params = [args.unstakeDelaySec];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> balanceOf(
    ({_i1.EthereumAddress account}) args, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[3];
    assert(checkSignature(function, '70a08231'));
    final params = [args.account];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as BigInt);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> depositTo(
    ({_i1.EthereumAddress account}) args, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[4];
    assert(checkSignature(function, 'b760faf9'));
    final params = [args.account];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<Deposits> deposits(
    ({_i1.EthereumAddress $param6}) args, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[5];
    assert(checkSignature(function, 'fc7e286d'));
    final params = [args.$param6];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return Deposits(response);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<dynamic> getDepositInfo(
    ({_i1.EthereumAddress account}) args, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[6];
    assert(checkSignature(function, '5287ce12'));
    final params = [args.account];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as dynamic);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> getNonce(
    ({_i1.EthereumAddress sender, BigInt key}) args, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[7];
    assert(checkSignature(function, '35567e1a'));
    final params = [
      args.sender,
      args.key,
    ];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as BigInt);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> getSenderAddress(
    ({_i2.Uint8List initCode}) args, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[8];
    assert(checkSignature(function, '9b249f69'));
    final params = [args.initCode];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i2.Uint8List> getUserOpHash(
    ({dynamic userOp}) args, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[9];
    assert(checkSignature(function, 'a6193531'));
    final params = [args.userOp];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i2.Uint8List);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> handleAggregatedOps(
    ({List<dynamic> opsPerAggregator, _i1.EthereumAddress beneficiary}) args, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[10];
    assert(checkSignature(function, '4b1d7cf5'));
    final params = [
      args.opsPerAggregator,
      args.beneficiary,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> handleOps(
    ({List<dynamic> ops, _i1.EthereumAddress beneficiary}) args, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[11];
    assert(checkSignature(function, '1fad948c'));
    final params = [
      args.ops,
      args.beneficiary,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> incrementNonce(
    ({BigInt key}) args, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[12];
    assert(checkSignature(function, '0bd28e3b'));
    final params = [args.key];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> innerHandleOp(
    ({_i2.Uint8List callData, dynamic opInfo, _i2.Uint8List context}) args, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[13];
    assert(checkSignature(function, '1d732756'));
    final params = [
      args.callData,
      args.opInfo,
      args.context,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> nonceSequenceNumber(
    ({_i1.EthereumAddress $param20, BigInt $param21}) args, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[14];
    assert(checkSignature(function, '1b2e01b8'));
    final params = [
      args.$param20,
      args.$param21,
    ];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as BigInt);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> simulateHandleOp(
    ({
      dynamic op,
      _i1.EthereumAddress target,
      _i2.Uint8List targetCallData
    }) args, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[15];
    assert(checkSignature(function, 'd6383f94'));
    final params = [
      args.op,
      args.target,
      args.targetCallData,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> simulateValidation(
    ({dynamic userOp}) args, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[16];
    assert(checkSignature(function, 'ee219423'));
    final params = [args.userOp];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> unlockStake({
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[17];
    assert(checkSignature(function, 'bb9fe6bf'));
    final params = [];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> withdrawStake(
    ({_i1.EthereumAddress withdrawAddress}) args, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[18];
    assert(checkSignature(function, 'c23a5cea'));
    final params = [args.withdrawAddress];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> withdrawTo(
    ({_i1.EthereumAddress withdrawAddress, BigInt withdrawAmount}) args, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[19];
    assert(checkSignature(function, '205c2878'));
    final params = [
      args.withdrawAddress,
      args.withdrawAmount,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// Returns a live stream of all AccountDeployed events emitted by this contract.
  Stream<AccountDeployed> accountDeployedEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('AccountDeployed');
    final filter = _i1.FilterOptions.events(
      contract: self,
      event: event,
      fromBlock: fromBlock,
      toBlock: toBlock,
    );
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(
        result.topics!,
        result.data!,
      );
      return AccountDeployed(
        decoded,
        result,
      );
    });
  }

  /// Returns a live stream of all BeforeExecution events emitted by this contract.
  Stream<BeforeExecution> beforeExecutionEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('BeforeExecution');
    final filter = _i1.FilterOptions.events(
      contract: self,
      event: event,
      fromBlock: fromBlock,
      toBlock: toBlock,
    );
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(
        result.topics!,
        result.data!,
      );
      return BeforeExecution(
        decoded,
        result,
      );
    });
  }

  /// Returns a live stream of all Deposited events emitted by this contract.
  Stream<Deposited> depositedEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('Deposited');
    final filter = _i1.FilterOptions.events(
      contract: self,
      event: event,
      fromBlock: fromBlock,
      toBlock: toBlock,
    );
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(
        result.topics!,
        result.data!,
      );
      return Deposited(
        decoded,
        result,
      );
    });
  }

  /// Returns a live stream of all SignatureAggregatorChanged events emitted by this contract.
  Stream<SignatureAggregatorChanged> signatureAggregatorChangedEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('SignatureAggregatorChanged');
    final filter = _i1.FilterOptions.events(
      contract: self,
      event: event,
      fromBlock: fromBlock,
      toBlock: toBlock,
    );
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(
        result.topics!,
        result.data!,
      );
      return SignatureAggregatorChanged(
        decoded,
        result,
      );
    });
  }

  /// Returns a live stream of all StakeLocked events emitted by this contract.
  Stream<StakeLocked> stakeLockedEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('StakeLocked');
    final filter = _i1.FilterOptions.events(
      contract: self,
      event: event,
      fromBlock: fromBlock,
      toBlock: toBlock,
    );
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(
        result.topics!,
        result.data!,
      );
      return StakeLocked(
        decoded,
        result,
      );
    });
  }

  /// Returns a live stream of all StakeUnlocked events emitted by this contract.
  Stream<StakeUnlocked> stakeUnlockedEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('StakeUnlocked');
    final filter = _i1.FilterOptions.events(
      contract: self,
      event: event,
      fromBlock: fromBlock,
      toBlock: toBlock,
    );
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(
        result.topics!,
        result.data!,
      );
      return StakeUnlocked(
        decoded,
        result,
      );
    });
  }

  /// Returns a live stream of all StakeWithdrawn events emitted by this contract.
  Stream<StakeWithdrawn> stakeWithdrawnEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('StakeWithdrawn');
    final filter = _i1.FilterOptions.events(
      contract: self,
      event: event,
      fromBlock: fromBlock,
      toBlock: toBlock,
    );
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(
        result.topics!,
        result.data!,
      );
      return StakeWithdrawn(
        decoded,
        result,
      );
    });
  }

  /// Returns a live stream of all UserOperationEvent events emitted by this contract.
  Stream<UserOperationEvent> userOperationEventEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('UserOperationEvent');
    final filter = _i1.FilterOptions.events(
      contract: self,
      event: event,
      fromBlock: fromBlock,
      toBlock: toBlock,
    );
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(
        result.topics!,
        result.data!,
      );
      return UserOperationEvent(
        decoded,
        result,
      );
    });
  }

  /// Returns a live stream of all UserOperationRevertReason events emitted by this contract.
  Stream<UserOperationRevertReason> userOperationRevertReasonEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('UserOperationRevertReason');
    final filter = _i1.FilterOptions.events(
      contract: self,
      event: event,
      fromBlock: fromBlock,
      toBlock: toBlock,
    );
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(
        result.topics!,
        result.data!,
      );
      return UserOperationRevertReason(
        decoded,
        result,
      );
    });
  }

  /// Returns a live stream of all Withdrawn events emitted by this contract.
  Stream<Withdrawn> withdrawnEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('Withdrawn');
    final filter = _i1.FilterOptions.events(
      contract: self,
      event: event,
      fromBlock: fromBlock,
      toBlock: toBlock,
    );
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(
        result.topics!,
        result.data!,
      );
      return Withdrawn(
        decoded,
        result,
      );
    });
  }
}

class Deposits {
  Deposits(List<dynamic> response)
      : deposit = (response[0] as BigInt),
        staked = (response[1] as bool),
        stake = (response[2] as BigInt),
        unstakeDelaySec = (response[3] as BigInt),
        withdrawTime = (response[4] as BigInt);

  final BigInt deposit;

  final bool staked;

  final BigInt stake;

  final BigInt unstakeDelaySec;

  final BigInt withdrawTime;
}

class AccountDeployed {
  AccountDeployed(
    List<dynamic> response,
    this.event,
  )   : userOpHash = (response[0] as _i2.Uint8List),
        sender = (response[1] as _i1.EthereumAddress),
        factory = (response[2] as _i1.EthereumAddress),
        paymaster = (response[3] as _i1.EthereumAddress);

  final _i2.Uint8List userOpHash;

  final _i1.EthereumAddress sender;

  final _i1.EthereumAddress factory;

  final _i1.EthereumAddress paymaster;

  final _i1.FilterEvent event;
}

class BeforeExecution {
  BeforeExecution(
    List<dynamic> response,
    this.event,
  );

  final _i1.FilterEvent event;
}

class Deposited {
  Deposited(
    List<dynamic> response,
    this.event,
  )   : account = (response[0] as _i1.EthereumAddress),
        totalDeposit = (response[1] as BigInt);

  final _i1.EthereumAddress account;

  final BigInt totalDeposit;

  final _i1.FilterEvent event;
}

class SignatureAggregatorChanged {
  SignatureAggregatorChanged(
    List<dynamic> response,
    this.event,
  ) : aggregator = (response[0] as _i1.EthereumAddress);

  final _i1.EthereumAddress aggregator;

  final _i1.FilterEvent event;
}

class StakeLocked {
  StakeLocked(
    List<dynamic> response,
    this.event,
  )   : account = (response[0] as _i1.EthereumAddress),
        totalStaked = (response[1] as BigInt),
        unstakeDelaySec = (response[2] as BigInt);

  final _i1.EthereumAddress account;

  final BigInt totalStaked;

  final BigInt unstakeDelaySec;

  final _i1.FilterEvent event;
}

class StakeUnlocked {
  StakeUnlocked(
    List<dynamic> response,
    this.event,
  )   : account = (response[0] as _i1.EthereumAddress),
        withdrawTime = (response[1] as BigInt);

  final _i1.EthereumAddress account;

  final BigInt withdrawTime;

  final _i1.FilterEvent event;
}

class StakeWithdrawn {
  StakeWithdrawn(
    List<dynamic> response,
    this.event,
  )   : account = (response[0] as _i1.EthereumAddress),
        withdrawAddress = (response[1] as _i1.EthereumAddress),
        amount = (response[2] as BigInt);

  final _i1.EthereumAddress account;

  final _i1.EthereumAddress withdrawAddress;

  final BigInt amount;

  final _i1.FilterEvent event;
}

class UserOperationEvent {
  UserOperationEvent(
    List<dynamic> response,
    this.event,
  )   : userOpHash = (response[0] as _i2.Uint8List),
        sender = (response[1] as _i1.EthereumAddress),
        paymaster = (response[2] as _i1.EthereumAddress),
        nonce = (response[3] as BigInt),
        success = (response[4] as bool),
        actualGasCost = (response[5] as BigInt),
        actualGasUsed = (response[6] as BigInt);

  final _i2.Uint8List userOpHash;

  final _i1.EthereumAddress sender;

  final _i1.EthereumAddress paymaster;

  final BigInt nonce;

  final bool success;

  final BigInt actualGasCost;

  final BigInt actualGasUsed;

  final _i1.FilterEvent event;
}

class UserOperationRevertReason {
  UserOperationRevertReason(
    List<dynamic> response,
    this.event,
  )   : userOpHash = (response[0] as _i2.Uint8List),
        sender = (response[1] as _i1.EthereumAddress),
        nonce = (response[2] as BigInt),
        revertReason = (response[3] as _i2.Uint8List);

  final _i2.Uint8List userOpHash;

  final _i1.EthereumAddress sender;

  final BigInt nonce;

  final _i2.Uint8List revertReason;

  final _i1.FilterEvent event;
}

class Withdrawn {
  Withdrawn(
    List<dynamic> response,
    this.event,
  )   : account = (response[0] as _i1.EthereumAddress),
        withdrawAddress = (response[1] as _i1.EthereumAddress),
        amount = (response[2] as BigInt);

  final _i1.EthereumAddress account;

  final _i1.EthereumAddress withdrawAddress;

  final BigInt amount;

  final _i1.FilterEvent event;
}
