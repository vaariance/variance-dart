// Mocks generated by Mockito 5.4.2 from annotations
// in pks_4337_sdk/test/common/contract_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:http/http.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i7;
import 'package:pks_4337_sdk/pks_4337_sdk.dart' as _i6;
import 'package:web3dart/json_rpc.dart' as _i5;
import 'package:web3dart/web3dart.dart' as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeClient_0 extends _i1.SmartFake implements _i2.Client {
  _FakeClient_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeEtherAmount_1 extends _i1.SmartFake implements _i3.EtherAmount {
  _FakeEtherAmount_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFuture_2<T1> extends _i1.SmartFake implements _i4.Future<T1> {
  _FakeFuture_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeRPCResponse_3 extends _i1.SmartFake implements _i5.RPCResponse {
  _FakeRPCResponse_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [BaseProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockBaseProvider extends _i1.Mock implements _i6.BaseProvider {
  @override
  String get rpcUrl => (super.noSuchMethod(
        Invocation.getter(#rpcUrl),
        returnValue: '',
        returnValueForMissingStub: '',
      ) as String);
  @override
  _i2.Client get client => (super.noSuchMethod(
        Invocation.getter(#client),
        returnValue: _FakeClient_0(
          this,
          Invocation.getter(#client),
        ),
        returnValueForMissingStub: _FakeClient_0(
          this,
          Invocation.getter(#client),
        ),
      ) as _i2.Client);
  @override
  String get url => (super.noSuchMethod(
        Invocation.getter(#url),
        returnValue: '',
        returnValueForMissingStub: '',
      ) as String);
  @override
  _i4.Future<BigInt> estimateGas(
    _i3.EthereumAddress? to,
    String? calldata,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #estimateGas,
          [
            to,
            calldata,
          ],
        ),
        returnValue: _i4.Future<BigInt>.value(_i7.dummyValue<BigInt>(
          this,
          Invocation.method(
            #estimateGas,
            [
              to,
              calldata,
            ],
          ),
        )),
        returnValueForMissingStub:
            _i4.Future<BigInt>.value(_i7.dummyValue<BigInt>(
          this,
          Invocation.method(
            #estimateGas,
            [
              to,
              calldata,
            ],
          ),
        )),
      ) as _i4.Future<BigInt>);
  @override
  _i4.Future<int> getBlockNumber() => (super.noSuchMethod(
        Invocation.method(
          #getBlockNumber,
          [],
        ),
        returnValue: _i4.Future<int>.value(0),
        returnValueForMissingStub: _i4.Future<int>.value(0),
      ) as _i4.Future<int>);
  @override
  _i4.Future<Map<String, BigInt>> getEip1559GasPrice() => (super.noSuchMethod(
        Invocation.method(
          #getEip1559GasPrice,
          [],
        ),
        returnValue: _i4.Future<Map<String, BigInt>>.value(<String, BigInt>{}),
        returnValueForMissingStub:
            _i4.Future<Map<String, BigInt>>.value(<String, BigInt>{}),
      ) as _i4.Future<Map<String, BigInt>>);
  @override
  _i4.Future<Map<String, BigInt>> getGasPrice() => (super.noSuchMethod(
        Invocation.method(
          #getGasPrice,
          [],
        ),
        returnValue: _i4.Future<Map<String, BigInt>>.value(<String, BigInt>{}),
        returnValueForMissingStub:
            _i4.Future<Map<String, BigInt>>.value(<String, BigInt>{}),
      ) as _i4.Future<Map<String, BigInt>>);
  @override
  _i4.Future<_i3.EtherAmount> getLegacyGasPrice() => (super.noSuchMethod(
        Invocation.method(
          #getLegacyGasPrice,
          [],
        ),
        returnValue: _i4.Future<_i3.EtherAmount>.value(_FakeEtherAmount_1(
          this,
          Invocation.method(
            #getLegacyGasPrice,
            [],
          ),
        )),
        returnValueForMissingStub:
            _i4.Future<_i3.EtherAmount>.value(_FakeEtherAmount_1(
          this,
          Invocation.method(
            #getLegacyGasPrice,
            [],
          ),
        )),
      ) as _i4.Future<_i3.EtherAmount>);
  @override
  _i4.Future<T> send<T>(
    String? function, [
    List<dynamic>? params,
  ]) =>
      (super.noSuchMethod(
        Invocation.method(
          #send,
          [
            function,
            params,
          ],
        ),
        returnValue: _i7.ifNotNull(
              _i7.dummyValueOrNull<T>(
                this,
                Invocation.method(
                  #send,
                  [
                    function,
                    params,
                  ],
                ),
              ),
              (T v) => _i4.Future<T>.value(v),
            ) ??
            _FakeFuture_2<T>(
              this,
              Invocation.method(
                #send,
                [
                  function,
                  params,
                ],
              ),
            ),
        returnValueForMissingStub: _i7.ifNotNull(
              _i7.dummyValueOrNull<T>(
                this,
                Invocation.method(
                  #send,
                  [
                    function,
                    params,
                  ],
                ),
              ),
              (T v) => _i4.Future<T>.value(v),
            ) ??
            _FakeFuture_2<T>(
              this,
              Invocation.method(
                #send,
                [
                  function,
                  params,
                ],
              ),
            ),
      ) as _i4.Future<T>);
  @override
  _i4.Future<_i5.RPCResponse> call(
    String? function, [
    List<dynamic>? params,
  ]) =>
      (super.noSuchMethod(
        Invocation.method(
          #call,
          [
            function,
            params,
          ],
        ),
        returnValue: _i4.Future<_i5.RPCResponse>.value(_FakeRPCResponse_3(
          this,
          Invocation.method(
            #call,
            [
              function,
              params,
            ],
          ),
        )),
        returnValueForMissingStub:
            _i4.Future<_i5.RPCResponse>.value(_FakeRPCResponse_3(
          this,
          Invocation.method(
            #call,
            [
              function,
              params,
            ],
          ),
        )),
      ) as _i4.Future<_i5.RPCResponse>);
}
