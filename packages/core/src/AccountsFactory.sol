// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@~/SimpleAccount.sol";
import "@~/SimplePasskeyAccount.sol";

/**
 * A sample factory contract for SimpleAccount
 * A UserOperations "initCode" holds the address of the factory, and a method call (to createAccount, in this sample factory).
 * The factory's createAccount returns the target account address even if it is already installed.
 * This way, the entryPoint.getSenderAddress() can be called either before or after the account is created.
 */
contract AccountsFactory {
  SimpleAccount public immutable simpleAccount;
  SimplePasskeyAccount public immutable simplePasskeyAccount;

  constructor(IEntryPoint _entryPoint) {
    simpleAccount = new SimpleAccount(_entryPoint);
    simplePasskeyAccount = new SimplePasskeyAccount(_entryPoint);
  }

  /**
   * create an account, and return its address.
   * returns the address even if the account is already deployed.
   * Note that during UserOperation execution, this method is called only if the account is not deployed.
   * This method returns an existing account address so that entryPoint.getSenderAddress() would work even after account creation
   */
  function createAccount(address owner, uint256 salt) public returns (SimpleAccount ret) {
    address addr = getAddress(owner, salt);
    uint codeSize = addr.code.length;
    if (codeSize > 0) {
      return SimpleAccount(payable(addr));
    }
    ret = SimpleAccount(
      payable(
        new ERC1967Proxy{salt: bytes32(salt)}(
          address(simpleAccount),
          abi.encodeCall(SimpleAccount.initialize, (owner))
        )
      )
    );
  }

  function createPasskeyAccount(
    bytes32 credentialHex,
    uint256 x,
    uint256 y,
    uint256 salt
  ) public returns (SimplePasskeyAccount ret) {
    address addr = getPasskeyAccountAddress(credentialHex, x, y, salt);
    uint codeSize = addr.code.length;
    if (codeSize > 0) {
      return SimplePasskeyAccount(payable(addr));
    }
    ret = SimplePasskeyAccount(
      payable(
        new ERC1967Proxy{salt: bytes32(salt)}(
          address(simplePasskeyAccount),
          abi.encodeCall(SimplePasskeyAccount.initialize, (credentialHex, x, y))
        )
      )
    );
  }

  /**
   * calculate the counterfactual address of this account as it would be returned by createAccount()
   */
  function getAddress(address owner, uint256 salt) public view returns (address) {
    return
      Create2.computeAddress(
        bytes32(salt),
        keccak256(
          abi.encodePacked(
            type(ERC1967Proxy).creationCode,
            abi.encode(address(simpleAccount), abi.encodeCall(SimpleAccount.initialize, (owner)))
          )
        )
      );
  }

  function getPasskeyAccountAddress(
    bytes32 credentialHex,
    uint256 x,
    uint256 y,
    uint256 salt
  ) public view returns (address) {
    return
      Create2.computeAddress(
        bytes32(salt),
        keccak256(
          abi.encodePacked(
            type(ERC1967Proxy).creationCode,
            abi.encode(
              address(simplePasskeyAccount),
              abi.encodeCall(SimplePasskeyAccount.initialize, (credentialHex, x, y))
            )
          )
        )
      );
  }
}
