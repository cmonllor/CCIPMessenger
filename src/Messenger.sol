// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19;


import {CCIPDriver} from "./CCIPDriver/CCIPDriver.sol";
import {ICCIPDriverConsumer} from "./CCIPDriver/ICCIPDriverConsumer.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title - A contract that consumes messages from a CCIP driver contract
 * @dev - This contract implements the ICCIPDriverConsumer interface and is used to consume messages from a CCIP driver contract.
 * The `processMessage` function should be called by the CCIP driver contract when a message is received.
 * The `processAcknowledgment` function should be called by the CCIP driver contract when an acknowledgment is received.
 * The contract should handle the message and acknowledgment data as needed.
 */

contract Messenger is ICCIPDriverConsumer {
    CCIPDriver private ccipDriver;

    address private s_router;
    address private s_link;

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
        s_router = _router;
        s_link = _link;        
    }

    function start() external {
        IERC20 link = IERC20(s_link);
        require(link.balanceOf(address(this)) >= 5 * 10**17, "Messenger: Not enough LINK to start");
        ccipDriver = CCIPDriver(s_router);
        link.transfer(address(ccipDriver), 5 * 10**17); // 0.5 LINK to receive messages
    }
    
    function fundDriver() external {
        IERC20 link = IERC20(s_link);
        link.transfer(address(ccipDriver), 5 * 10**17); // 0.5 LINK
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

    /**
     * @dev - Send a message to a destination chain
     * @param _destNetwork - The network ID of the destination chain
     * @param _destination - The address of the receiver on the destination chain
     * @param _data - The message data
     * @return messageId - The unique ID of the message
     */
    function sendMessage(uint64 _destNetwork, address _destination, bytes calldata _data) external returns (bytes32 messageId){
        IERC20 link = IERC20(s_link);
        link.transfer(address(ccipDriver), 5 * 10**17); // 0.5 LINK

        bytes32 id =  ccipDriver.sendMessagePayLINK(_destNetwork, _destination, _data);
        waitingAck[id] = true;

        return id;
    }
}