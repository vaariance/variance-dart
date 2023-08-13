// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

contract HelpScript is Script {
    function setUp() public {}

    function run() public {
        bytes32 typehash = keccak256(
            "PasskeysExecute(address safe,address to,uint240 value,uint16 nonce,bytes calldata data)"
        );
        console.logBytes32(typehash);
        vm.broadcast();
    }
}
