// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";


import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";

import "./Helper.sol";
import "./MCToken.sol";

contract MCTokenKid is CCIPReceiver, Helper {
    address TokenAddress;

    IRouterClient private router;
    IERC20 private linkToken;


    string public name;
    string public symbol;

    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Used to make sure contract has enough balance.
    error NothingToWithdraw(); // Used when trying to withdraw Ether but there's nothing to withdraw.
    error FailedToWithdrawEth(address owner, address target, uint256 value); // Used when the withdrawal of Ether fails.
    error DestinationChainNotAllowlisted(uint64 destinationChainSelector); // Used when the destination chain has not been allowlisted by the contract owner.
    error SourceChainNotAllowlisted(uint64 sourceChainSelector); // Used when the source chain has not been allowlisted by the contract owner.
    error SenderNotAllowlisted(address sender); // Used when the sender has not been allowlisted by the contract owner.
    error InvalidReceiverAddress(); // Used when the receiver address is 0.

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

    bytes32 private s_lastReceivedMessageId; // Store the last received messageId.
    string private s_lastReceivedText; // Store the last received text.

    // Mapping to keep track of allowlisted destination chains.
    mapping(uint64 => bool) public allowlistedDestinationChains;

    // Mapping to keep track of allowlisted source chains.
    mapping(uint64 => bool) public allowlistedSourceChains;

    // Mapping to keep track of allowlisted senders.
    mapping(address => bool) public allowlistedSenders;


    function getRouter() returns (address)  {
        SupportedNetworks chain = getChain();
        if ( chain == SupportedNetworks.ARBITRUM_SEPOLIA ){
            return routerArbitrumSepolia;
        } else if ( chain == SupportedNetworks.AVALANCHE_FUJI ){
            return routerAvalancheFuji;
        } else if ( chain == SupportedNetworks.ETHEREUM_SEPOLIA ){
            return routerEthereumSepolia;
        } else if ( chain == SupportedNetworks.BASE_SEPOLIA ){
            return routerBaseSepolia;
        } else if ( chain == SupportedNetworks.POLYGON_MUMBAI ){
            return routerPolygonMumbai;
        } else if ( chain == SupportedNetworks.BINANCE_SMART_CHAIN_TESTNET ){
            return routerBinanceSmartChainTestnet;
        } else {
            revert("Unknown chain");
        }
    }

    constructor() CCIPReceiver( getRouter() ) {
        router = IRouterClient( getRouter() );
        linkToken = IERC20( router.linkToken() );
    }

    function getChain() public view returns (SupportedNetworks) {
        //call chainId
        //seek on Helper.sol
        uint256 chainId = block.chainid;
        if ( chainId == chainIdArbitrumSepolia ){
            return SupportedNetworks.ARBITRUM_SEPOLIA;
        } else if ( chainId == chainIdAvalancheFuji ){
            return SupportedNetworks.AVALANCHE_FUJI;
        } else if ( chainId == chainIdEthereumSepolia ){
            return SupportedNetworks.ETHEREUM_SEPOLIA;
        } else if ( chainId == chainIdBaseSepolia ){
            return SupportedNetworks.BASE_SEPOLIA;
        } else if ( chainId == chainIdPolygonMumbai ){
            return SupportedNetworks.POLYGON_MUMBAI;
        } else if ( chainId == chainIdBinanceSmartChainTestnet ){
            return SupportedNetworks.BINANCE_SMART_CHAIN_TESTNET;
        } else if ( chainId == chainIdBinanceSmartChain ){
            revert("mainnet? are you crazy?");
        } else if ( chainId == chainIdAvalancheMainnet ){
            revert("mainnet? are you crazy?");
        } else if ( chainId == chainIdEthereumMainnet ){
            revert("mainnet? are you crazy?");
        } else if ( chainId == chainIdPolygonMainnet ){
            revert("mainnet? are you crazy?");
        } else {
            revert("Unknown chain");
        }

    }



}
