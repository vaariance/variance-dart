part of '../../variance.dart';

class SmartWallet with _PluginManager, _GasSettings implements SmartWalletBase {
  final Chain _chain;

  final EthereumAddress _walletAddress;

  Uint8List _initCode;

  SmartWallet(this._chain, this._walletAddress, this._initCode);

  @override
  EthereumAddress get address => _walletAddress;

  @override
  Future<EtherAmount> get balance =>
      plugin<Contract>("contract").getBalance(_walletAddress);

  @override
  Future<bool> get isDeployed =>
      plugin<Contract>("contract").deployed(_walletAddress);

  @override
  String get initCode => hexlify(_initCode);

  @override
  Future<BigInt> get initCodeGas => _initCodeGas;

  @override
  Future<Uint256> get nonce => _getNonce();

  @override
  String? get toHex => _walletAddress.hexEip55;

  Future<BigInt> get _initCodeGas => plugin<JsonRPCProviderBase>('jsonRpc')
      .estimateGas(_chain.entrypoint.address, initCode);

  @override
  void dangerouslySetInitCode(Uint8List code) {
    _initCode = code;
  }

  @override
  UserOperation buildUserOperation({
    required Uint8List callData,
    BigInt? customNonce,
  }) =>
      UserOperation.partial(
          callData: callData,
          initCode: _initCode,
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
          .sendUserOperation(
              op.toMap(), _chain.entrypoint, plugin('jsonRpc').rpc)
          .catchError((e) => throw SendError(e.toString(), op));

  @override
  Future<UserOperationResponse> sendUserOperation(UserOperation op) =>
      signUserOperation(op)
          .then(sendSignedUserOperation)
          .catchError((e) => retryOp(() => sendSignedUserOperation(op), e));

  @override
  Future<UserOperation> signUserOperation(UserOperation userOp,
      {bool update = true, int? index}) async {
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
      Future.wait<dynamic>([
        _getNonce(),
        plugin<JsonRPCProviderBase>('jsonRpc').getGasPrice()
      ]).then((responses) {
        op = op.copyWith(
            nonce: op.nonce > BigInt.zero ? op.nonce : responses[0].value,
            initCode: responses[0] > BigInt.zero ? Uint8List(0) : null,
            signature: plugin<MSI>('signer').dummySignature);
        return _updateUserOperationGas(op, feePerGas: responses[1]);
      });

  Future<UserOperation> _updateUserOperationGas(UserOperation op,
          {Map<String, EtherAmount>? feePerGas}) =>
      plugin<BundlerProviderBase>('bundler')
          .estimateUserOperationGas(op.toMap(), _chain.entrypoint)
          .then((opGas) => op.updateOpGas(opGas, feePerGas))
          .then((op) => multiply(op))
          .catchError((e) => throw GasEstimationError(e.toString(), op));
}
