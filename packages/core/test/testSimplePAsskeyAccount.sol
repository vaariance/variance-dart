// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "@~/SimplePasskeyAccount.sol";
import "@~/AccountsFactory.sol";
import "./Config.sol";

contract SimplePasskeyAccountHarness is SimplePasskeyAccount {
  constructor(IEntryPoint _entryPoint) SimplePasskeyAccount(_entryPoint) {}

  function exposed_validateSignature(
    UserOperation calldata userOp,
    bytes32 userOpHash
  ) public returns (uint256 validationData) {
    return _validateSignature(userOp, userOpHash);
  }
}

contract TestSimplePasskeyAccount is Test {
  SimplePasskeyAccountHarness simplePasskeyAccount;
  SimplePasskeyAccountHarness account;
  Config.NetworkConfig config;

  function setUp() public {
    Config conf = new Config();
    config = conf.getActiveNetworkConfig();
    simplePasskeyAccount = new SimplePasskeyAccountHarness(IEntryPoint(config.entrypoint));
    account = SimplePasskeyAccountHarness(
      payable(
        new ERC1967Proxy{salt: bytes32(0)}(
          address(simplePasskeyAccount),
          abi.encodeCall(
            SimplePasskeyAccount.initialize,
            (config.credentialHex, config.xy[0], config.xy[1])
          )
        )
      )
    );
  }

  function buildUserOp() internal view returns (UserOperation memory) {
    return
      UserOperation({
        sender: address(0),
        nonce: 0,
        initCode: new bytes(0),
        callData: new bytes(0),
        callGasLimit: 0x0,
        verificationGasLimit: 0x0,
        preVerificationGas: 0x0,
        maxFeePerGas: 0x0,
        maxPriorityFeePerGas: 0x0,
        paymasterAndData: new bytes(0),
        signature: abi.encode(
          config.rs[0],
          config.rs[1],
          config.authenticatorData,
          config.clientDataJsonPre,
          config.clientDataJsonPost
        )
      });
  }

  function testValidateSignature() public {
    uint256 value = account.exposed_validateSignature(buildUserOp(), config.testHash);
    uint256 expected = 0;
    assertEq(value, expected);
  }

  function testGetCredentialId() public {
    string memory value = account.getCredentialIdBase64();
    string memory expected = config.credentialId;
    assertEq(keccak256(bytes(value)), keccak256(bytes(expected)));
  }
}
