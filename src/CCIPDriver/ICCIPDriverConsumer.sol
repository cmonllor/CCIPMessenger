// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
    * @title - Interface for consuming messages from a CCIP driver contract
    * @dev - This interface should be implemented by any contract that wishes to consume messages from a CCIP driver contract.
    * The `processMessage` function should be called by the CCIP driver contract when a message is received.
    * The `processAcknowledgment` function should be called by the CCIP driver contract when an acknowledgment is received.
    * The contract implementing this interface should handle the message and acknowledgment data as needed.
    * @dev SECURITY WARNING: Strict access control must be implemented in the functions that call
    *  `processMessage`, `processAcknowledgment` and `processError` to avoid reentrancy attacks.
 */
interface ICCIPDriverConsumer {
    function processMessage(bytes32 _messageId, address _sender, uint64 _networkId, bytes calldata _data)  external returns (bool);
    function processAcknowledgment(bytes32 _messageId, address _sender, uint64 _networkId, bytes calldata _data) external returns (bool);
    function processError(bytes32 _messageId, address _sender, uint64 _networkId, bytes calldata _data) external;
}