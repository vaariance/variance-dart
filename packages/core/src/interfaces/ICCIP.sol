// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

interface ICCIP {
  error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees);
  error NothingToWithdraw();
  error DestinationChainNotWhitelisted(uint64 destinationChainSelector);

  event TokensTransferred(
    bytes32 indexed messageId, // The unique ID of the message.
    uint64 indexed destinationChainSelector, // The chain selector of the destination chain.
    address receiver, // The address of the receiver on the destination chain.
    address token, // The token address that was transferred.
    uint256 tokenAmount, // The token amount that was transferred.
    address feeToken, // the token address used to pay CCIP fees.
    uint256 fees // The fees paid for sending the message.
  );

  function getCCIPFee(
    uint64 destinationChainSelector,
    address receiver,
    IERC20 token,
    uint256 amount
  ) external view returns (uint256);
}
