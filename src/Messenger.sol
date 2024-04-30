// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19;


import {CCIPDriver} from "./CCIPDriver/CCIPDriver.sol";
import {ICCIPDriverConsumer} from "./CCIPDriver/ICCIPDriverConsumer.sol";

/**
 * @title - A contract that consumes messages from a CCIP driver contract
 * @dev - This contract implements the ICCIPDriverConsumer interface and is used to consume messages from a CCIP driver contract.
 * The `processMessage` function should be called by the CCIP driver contract when a message is received.
 * The `processAcknowledgment` function should be called by the CCIP driver contract when an acknowledgment is received.
 * The contract should handle the message and acknowledgment data as needed.
 */

contract Messenger is ICCIPDriverConsumer {
    CCIPDriver private ccipDriver;

    mapping(bytes32 => bool) private waitingAck;

    event MessageReceived(
        bytes32 indexed messageId, // The unique ID of the CCIP message.
        uint64 indexed sourceChainSelector, // The chain selector of the source chain.
        address sender, // The address of the sender from the source chain.
        bytes data // The text that was received.
    );

    event MessageSent(
        bytes32 indexed messageId, // The unique ID of the CCIP message.
        uint64 indexed destinationChainSelector, // The chain selector of the destination chain.
        address receiver, // The address of the receiver on the destination chain.
        bytes data, // The text being sent.
        address feeToken, // the token address used to pay CCIP fees.
        uint256 fees // The fees paid for sending the CCIP message.
    );

    event AcknowledgmentReceived(
        bytes32 indexed messageId, // The unique ID of the CCIP message.
        uint64 indexed destinationChainSelector, // The chain selector of the destination chain.
        address receiver, // The address of the receiver on the destination chain.
        bytes data // The acknowledgment data.
    );

    event ErrorReceived(
        bytes32 indexed messageId, // The unique ID of the CCIP message.
        uint64 indexed destinationChainSelector, // The chain selector of the destination chain.
        address receiver, // The address of the receiver on the destination chain.
        bytes data // The error data.
    );

    constructor(address _router, address _link) {
        ccipDriver = new CCIPDriver(_router, _link);
    }

    function addPartner(address _partner, uint64 _networkId) external  {
        ccipDriver.allowlistDestinationChain(_networkId, true);
        ccipDriver.allowlistSourceChain(_networkId, true);
        ccipDriver.allowlistSender(_partner, true);
    }

    /**
     * @dev - Process a message received from the CCIP driver contract
     * @param _messageId - The unique ID of the message
     * @param _sender - The address of the sender
     * @param _networkId - The network ID of the sender
     * @param _data - The message data
     * @return - True if the message was processed successfully
     */
    function processMessage(bytes32 _messageId, address _sender, uint64 _networkId, bytes calldata _data) external override returns (bool) {
        // Process the message data as needed
        emit MessageReceived(_messageId, _networkId, _sender, _data);
        ccipDriver.acknowledgePayLINK(_messageId, _sender, _networkId);
        return true;
    }

    /**
     * @dev - Process an acknowledgment received from the CCIP driver contract
     * @param _messageId - The unique ID of the message
     * @param _sender - The address of the sender
     * @param _networkId - The network ID of the sender
     * @param _data - The acknowledgment data
     * @return - True if the acknowledgment was processed successfully
     */
    function processAcknowledgment(bytes32 _messageId, address _sender, uint64 _networkId, bytes calldata _data) external override returns (bool) {
        // Process the acknowledgment data as needed
        if(waitingAck[_messageId] ){
            emit AcknowledgmentReceived(_messageId, _networkId, _sender, _data);
            waitingAck[_messageId] = false;
            return true;
        }
        return false;       
    }

    /**
     * @dev - Process an error received from the CCIP driver contract
     * @param _messageId - The unique ID of the message
     * @param _sender - The address of the sender
     * @param _networkId - The network ID of the sender
     * @param _data - The error data
     */
    function processError(bytes32 _messageId, address _sender, uint64 _networkId, bytes calldata _data) external override {
        emit ErrorReceived(_messageId, _networkId, _sender, _data);
        waitingAck[_messageId] = false;
    }
}