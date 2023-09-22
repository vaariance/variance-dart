// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

contract Config {
  struct NetworkConfig {
    address entrypoint;
    string credentialId;
    bytes32 credentialHex;
    uint256[2] xy;
    uint256[2] rs;
    string clientDataJsonPre;
    string clientDataJsonPost;
    string clientData;
    bytes authenticatorData;
    bytes32 testHash;
  }

  NetworkConfig activeNetworkConfig;

  mapping(uint256 => NetworkConfig) public chainIdToNetworkConfig;

  constructor() {
    chainIdToNetworkConfig[31337] = getAnvilEthConfig();
    activeNetworkConfig = chainIdToNetworkConfig[block.chainid];
  }

  function getActiveNetworkConfig() external view returns (NetworkConfig memory) {
    return activeNetworkConfig;
  }

  function getAnvilEthConfig() internal pure returns (NetworkConfig memory anvilNetworkConfig) {
    uint256[2] memory q;
    uint256[2] memory rs;
    q[0] = 0xf5dee907a9f28e50eab51b699ff6becf2783fa5f6cf0d83186e6c8a29f84e7a6;
    q[1] = 0x6e5794995bfe01a6166731db5de6caf5a9cf232364cb816ac6626d46abf8d759;
    rs[0] = 0xe017c9b829f0d550c9a0f1d791d460485b774c5e157d2eaabdf690cba2a62726;
    rs[1] = 0xb3e3a3c5022dc5301d272a752c05053941b1ca608bf6bc8ec7c71dfe15d53059;
    anvilNetworkConfig = NetworkConfig({
      entrypoint: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789,
      credentialId: "EUQ8dgl3CB-p6SewjKsmj25ng2IfKkAQLYzFhube47w",
      credentialHex: 0x11443c760977081fa9e927b08cab268f6e6783621f2a40102d8cc586e6dee3bc,
      xy: q,
      rs: rs,
      clientDataJsonPre: '{"type":"webauthn.get","challenge":"',
      clientDataJsonPost: '","origin":"api.webauthn.io"}',
      clientData: '{"type":"webauthn.get","challenge":"1BWo2FD1icnHUjlcCCurRR6Iltb1GfTUYQmnzAZVq3M","origin":"api.webauthn.io"}',
      authenticatorData: hex"205f5f63c4a6cebdc67844b75186367e6d2e4f19b976ab0affefb4e981c224350500000001",
      testHash: 0xd415a8d850f589c9c752395c082bab451e8896d6f519f4d46109a7cc0655ab73
    });
  }
}
