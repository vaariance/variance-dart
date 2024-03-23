part of '../../variance.dart';

class SmartWallet with _PluginManager, _GasSettings implements SmartWalletBase {
  final Chain _chain;

  final EthereumAddress _walletAddress;

  Uint8List _initCalldata;

  SmartWallet(this._chain, this._walletAddress, this._initCalldata);

  @override
  EthereumAddress get address => _walletAddress;

  @override
  Future<EtherAmount> get balance =>
      plugin<Contract>("contract").getBalance(_walletAddress);

  @override
  Future<bool> get isDeployed =>
      plugin<Contract>("contract").deployed(_walletAddress);

  @override
  String get initCode =>
      _chain.accountFactory!.hexEip55 + hexlify(_initCalldata).substring(2);

  @override
  Future<BigInt> get initCodeGas => _initCodeGas;

  @override
  Future<Uint256> get nonce => _getNonce();

  @override
  String? get toHex => _walletAddress.hexEip55;

  Uint8List get _initCodeBytes {
    List<int> extended = _chain.accountFactory!.addressBytes.toList();
    extended.addAll(_initCalldata);
    return Uint8List.fromList(extended);
  }

  Future<BigInt> get _initCodeGas => plugin<RPCProviderBase>('jsonRpc')
      .estimateGas(_chain.entrypoint.address, initCode);

  @override
  void dangerouslySetInitCallData(Uint8List code) {
    _initCalldata = code;
  }

  @override
  UserOperation buildUserOperation({
    required Uint8List callData,
    BigInt? customNonce,
  }) =>
      UserOperation.partial(
          callData: callData,
          initCode: _initCodeBytes,
          sender: _walletAddress,
          nonce: customNonce);

  @override
  Future<UserOperationResponse> send(
          EthereumAddress recipient, EtherAmount amount) =>
      sendUserOperation(buildUserOperation(
          callData:
              Contract.execute(_walletAddress, to: recipient, amount: amount)));

  @override
  Future<UserOperationResponse> sendTransaction(
          EthereumAddress to, Uint8List encodedFunctionData,
          {EtherAmount? amount}) =>
      sendUserOperation(buildUserOperation(
          callData: Contract.execute(_walletAddress,
              to: to, amount: amount, innerCallData: encodedFunctionData)));

  @override
  Future<UserOperationResponse> sendBatchedTransaction(
          List<EthereumAddress> recipients, List<Uint8List> calls,
          {List<EtherAmount>? amounts}) =>
      sendUserOperation(buildUserOperation(
          callData: Contract.executeBatch(
              walletAddress: _walletAddress,
              recipients: recipients,
              amounts: amounts,
              innerCalls: calls)));

  @override
  Future<UserOperationResponse> sendSignedUserOperation(UserOperation op) =>
      plugin<BundlerProviderBase>('bundler')
          .sendUserOperation(op.toMap(), _chain.entrypoint)
          .catchError((e) => throw SendError(e.toString(), op));

  @override
  Future<UserOperationResponse> sendUserOperation(UserOperation op,
          {String? id}) =>
      signUserOperation(op, id: id)
          .then(sendSignedUserOperation)
          .catchError((e) => retryOp(() => sendSignedUserOperation(op), e));

  @override
  Future<UserOperation> signUserOperation(UserOperation userOp,
      {bool update = true, String? id, int? index}) async {
    if (update) userOp = await _updateUserOperation(userOp);

    final opHash = userOp.hash(_chain);

    if (hasPlugin('paymaster')) {
      userOp = await plugin<Paymaster>('paymaster').intercept(userOp);
    }

    Uint8List signature =
        await plugin<MSI>('signer').personalSign(opHash, index: index);

    userOp.signature = hexlify(signature);
    userOp.validate(userOp.nonce > BigInt.zero, initCode);

    return userOp;
  }

  Future<Uint256> _getNonce() => isDeployed.then((deployed) => !deployed
      ? Future.value(Uint256.zero)
      : plugin<Contract>("contract")
          .call(_chain.entrypoint.address, ContractAbis.get('getNonce'),
              "getNonce",
              params: [_walletAddress, BigInt.zero])
          .then((value) => Uint256(value[0]))
          .catchError((e) => throw NonceError(e.toString(), _walletAddress)));

  Future<UserOperation> _updateUserOperation(UserOperation op) =>
      Future.wait<dynamic>(
              [_getNonce(), plugin<RPCProviderBase>('jsonRpc').getGasPrice()])
          .then((responses) {
        op = op.copyWith(
            nonce: op.nonce > BigInt.zero ? op.nonce : responses[0].value,
            initCode: responses[0] > BigInt.zero ? Uint8List(0) : null,
            signature: plugin<MSI>('signer').dummySignature);
        return _updateUserOperationGas(op,
            feePerGas: _formatGasFees(responses[1]));
      });

  // supporting v07 migration
  Map<String, T> _formatGasFees<T>(Map<String, EtherAmount> feePerGas) {
    if (_chain.entrypoint == EntryPoint.v07) {
      final gasFees = <String, T>{};
      final high128 = feePerGas['maxPriorityFeePerGas']!.getInWei;
      final low128 = feePerGas['maxFeePerGas']!.getInWei;
      gasFees['gasFees'] = packUints(high128, low128) as T;
      return gasFees;
    }
    return feePerGas as Map<String, T>;
  }

  Future<UserOperation> _updateUserOperationGas(UserOperation op,
          {Map<String, EtherAmount>? feePerGas}) =>
      plugin<BundlerProviderBase>('bundler')
          .estimateUserOperationGas(op.toMap(), _chain.entrypoint)
          .then((opGas) => op.updateOpGas(opGas, feePerGas))
          .then((op) => multiply(op))
          .catchError((e) => throw EstimateError(e.toString(), op));
}

typedef MSI = MultiSignerInterface;
