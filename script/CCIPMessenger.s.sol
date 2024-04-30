// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";

import {Messenger} from "../src/Messenger.sol";
import "../src/Helper.sol";


contract DeployMessengerFujiScript is Script, Helper{  
    function run() public {
        uint256 fuji_privatekey = vm.envUint("FUJI_ACCOUNT_PRIVATE_KEY");

        vm.startBroadcast(fuji_privatekey);
        uint256 currentChainId = block.chainid;
        require(currentChainId == chainIdAvalancheFuji, "This script is only for Fuji testnet");
        Messenger messenger = new Messenger(routerAvalancheFuji, linkAvalancheFuji);

        console.log("Messenger deployed at address: ", address(messenger));

        vm.stopBroadcast();    
    }
}

contract DeployMessengerSepoliaScript is Script, Helper{  
    function run() public {
        uint256 sepolia_privatekey = vm.envUint("SEPOLIA_ACCOUNT_PRIVATE_KEY");

        vm.startBroadcast(sepolia_privatekey);
        uint256 currentChainId = block.chainid;
        require(currentChainId == chainIdEthereumSepolia, "This script is only for Ethereum Seppolia testnet");
        Messenger messenger = new Messenger(routerEthereumSepolia , linkEthereumSepolia);

        console.log("Messenger deployed at address: ", address(messenger));

        vm.stopBroadcast();    
    }
}

contract UpdateFujiPartnerScript is Script, Helper{  
    function run(address _messenger, address _partner ) public {
        uint256 fuji_privatekey = vm.envUint("FUJI_ACCOUNT_PRIVATE_KEY");

        vm.startBroadcast(fuji_privatekey);
        uint256 currentChainId = block.chainid;
        require(currentChainId == chainIdAvalancheFuji, "This script is only for Fuji testnet");
        Messenger messenger = Messenger(_messenger);
        messenger.addPartner(_partner, chainIdEthereumSepolia);

        console.log("Partner added");

        vm.stopBroadcast();    
    }
}

contract UpdateSepoliaPartnerScript is Script, Helper{  
    function run(address _messenger, address _partner ) public {
        uint256 sepolia_privatekey = vm.envUint("SEPOLIA_ACCOUNT_PRIVATE_KEY");

        vm.startBroadcast(sepolia_privatekey);
        uint256 currentChainId = block.chainid;
        require(currentChainId == chainIdEthereumSepolia, "This script is only for Ethereum Seppolia testnet");
        Messenger messenger = Messenger(_messenger);
        messenger.addPartner(_partner, chainIdAvalancheFuji);

        console.log("Partner added");

        vm.stopBroadcast();    
    }
}

