import 'package:flutter_test/flutter_test.dart';
import 'package:pks_4337_sdk/src/modules/alchemy_api/alchemy_api.dart';
import 'package:pks_4337_sdk/src/common/uint256.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  group('ERC20 Tests', () {
    test('encodeERC20ApproveCall should return a correct hex encoded calldata',
        () {
      final spender =
          EthereumAddress.fromHex("0x104EDD9708fFeeCd0b6bAaA37387E155Bce7d060");
      final tokenContract =
          EthereumAddress.fromHex("0xdAC17F958D2ee523a2206206994597C13D831ec7");
      final amount = Uint256(BigInt.from(1000000000000000000)).toWei();
      final expected = hexToBytes(
          "0x095ea7b3000000000000000000000000104edd9708ffeecd0b6baaa37387e155bce7d0600000000000000000000000000000000000000000000000000de0b6b3a7640000");

      final calldata = AlchemyTokenApi.encodeERC20ApproveCall(
          tokenContract, spender, amount);

      expect(calldata, expected);
    });

    test('encodeERC20TransferCall should return a correct hex encoded calldata',
        () {
      final spender =
          EthereumAddress.fromHex("0x104EDD9708fFeeCd0b6bAaA37387E155Bce7d060");
      final tokenContract =
          EthereumAddress.fromHex("0xdAC17F958D2ee523a2206206994597C13D831ec7");
      final amount = Uint256(BigInt.from(1000000000000000000)).toWei();
      final expected = hexToBytes(
          "0xa9059cbb000000000000000000000000104edd9708ffeecd0b6baaa37387e155bce7d0600000000000000000000000000000000000000000000000000de0b6b3a7640000");

      final calldata = AlchemyTokenApi.encodeERC20TransferCall(
          tokenContract, spender, amount);

      expect(calldata, expected);
    });
    test(
        'Token approve should return a user operation with the correct execute calldata',
        () {
      final wallet =
          EthereumAddress.fromHex("0xE1baa8F32Ac4Aa03031bbD6B6a970ab1892195ee");
      final spender =
          EthereumAddress.fromHex("0x104EDD9708fFeeCd0b6bAaA37387E155Bce7d060");
      final tokenContract =
          EthereumAddress.fromHex("0xdAC17F958D2ee523a2206206994597C13D831ec7");
      final amount = Uint256(BigInt.from(1000000000000000000)).toWei();
      const expected =
          "0xb61d27f6000000000000000000000000dac17f958d2ee523a2206206994597c13d831ec7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000044095ea7b3000000000000000000000000104edd9708ffeecd0b6baaa37387e155bce7d0600000000000000000000000000000000000000000000000000de0b6b3a764000000000000000000000000000000000000000000000000000000000000";
      final token = Token(tokenContract, EtherAmount.zero(), null);

      final uOp = token.approveToken(wallet, spender, amount);

      expect(uOp.callData, expected);
    });
    test(
        'Token transfer should return a user operation with the correct execute calldata',
        () {
      final wallet =
          EthereumAddress.fromHex("0xE1baa8F32Ac4Aa03031bbD6B6a970ab1892195ee");
      final spender =
          EthereumAddress.fromHex("0x104EDD9708fFeeCd0b6bAaA37387E155Bce7d060");
      final tokenContract =
          EthereumAddress.fromHex("0xdAC17F958D2ee523a2206206994597C13D831ec7");
      final amount = Uint256(BigInt.from(1000000000000000000)).toWei();
      const expected =
          "0xb61d27f6000000000000000000000000dac17f958d2ee523a2206206994597c13d831ec7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000044a9059cbb000000000000000000000000104edd9708ffeecd0b6baaa37387e155bce7d0600000000000000000000000000000000000000000000000000de0b6b3a764000000000000000000000000000000000000000000000000000000000000";
      final token = Token(tokenContract, EtherAmount.zero(), null);

      final uOp = token.transferToken(wallet, spender, amount);

      expect(uOp.callData, expected);
    });
  });
}
