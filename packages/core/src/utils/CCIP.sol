// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IRouterClient as Router} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client as ccip} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {LinkTokenInterface as Link} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import {ICCIP, IERC20} from "@~/interfaces/ICCIP.sol";

contract CCIP is ICCIP {
  Router immutable _router;
  Link immutable linkToken;

  constructor(address router, address _link) {
    _router = Router(router);
    linkToken = Link(_link);
  }

  /// @param destinationChainSelector The identifier (aka selector) for the destination blockchain.
  /// @param receiver The address of the recipient on the destination blockchain.
  /// @param token token address.
  /// @param amount token amount.
  /// @return calculated gas fee for the transfer.
  function getCCIPFee(
    uint64 destinationChainSelector,
    address receiver,
    IERC20 token,
    uint256 amount
  ) external view returns (uint256) {
    ccip.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(
      receiver,
      token,
      amount,
      address(0)
    );
    return _router.getFee(destinationChainSelector, evm2AnyMessage);
  }

  /// @notice Transfer tokens to receiver on the destination chain.
  /// @param destinationChainSelector The identifier (aka selector) for the destination blockchain.
  /// @param receiver The address of the recipient on the destination blockchain.
  /// @param token token address.
  /// @param amount token amount.
  /// @return messageId The ID of the message that was sent.
  function _transferAcross(
    uint64 destinationChainSelector,
    address receiver,
    IERC20 token,
    uint256 amount
  ) internal returns (bytes32 messageId) {
    ccip.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(
      receiver,
      token,
      amount,
      address(0)
    );
    uint256 fees = _router.getFee(destinationChainSelector, evm2AnyMessage);

    if (fees > address(this).balance) revert NotEnoughBalance(address(this).balance, fees);

    token.approve(address(_router), amount);

    messageId = _router.ccipSend{value: fees}(destinationChainSelector, evm2AnyMessage);
    emit TokensTransferred(
      messageId,
      destinationChainSelector,
      receiver,
      address(token),
      amount,
      address(0),
      fees
    );
    return messageId;
  }

  /// @notice Construct a CCIP message.
  /// @dev This function will create an EVM2AnyMessage struct with all the necessary information for tokens transfer.
  /// @param receiver The address of the receiver.
  /// @param token The token to be transferred.
  /// @param amount The amount of the token to be transferred.
  /// @param feeTokenAddress The address of the token used for fees. Set address(0) for native gas.
  /// @return Client.EVM2AnyMessage Returns an EVM2AnyMessage struct which contains information for sending a CCIP message.
  function _buildCCIPMessage(
    address receiver,
    IERC20 token,
    uint256 amount,
    address feeTokenAddress
  ) internal pure returns (ccip.EVM2AnyMessage memory) {
    ccip.EVMTokenAmount[] memory tokenAmounts = new ccip.EVMTokenAmount[](1);
    ccip.EVMTokenAmount memory tokenAmount = ccip.EVMTokenAmount({
      token: address(token),
      amount: amount
    });
    tokenAmounts[0] = tokenAmount;
    ccip.EVM2AnyMessage memory evm2AnyMessage = ccip.EVM2AnyMessage({
      receiver: abi.encode(receiver),
      data: "",
      tokenAmounts: tokenAmounts,
      extraArgs: ccip._argsToBytes(ccip.EVMExtraArgsV1({gasLimit: 0, strict: false})),
      feeToken: feeTokenAddress
    });
    return evm2AnyMessage;
  }
}
