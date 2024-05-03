// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";

import {Messenger} from "../src/Messenger.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./Helper.sol";


contract DeployMessengerFujiScript is Script, Helper{  
    function run() public {
        uint256 fuji_privatekey = vm.envUint("FUJI_ACCOUNT_PRIVATE_KEY");

        vm.startBroadcast(fuji_privatekey);
        
        Messenger messenger = new Messenger(routerAvalancheFuji, linkAvalancheFuji);

        console.log("Messenger deployed at address: ", address(messenger));

        IERC20 link = IERC20(linkAvalancheFuji);

        uint256 balance = link.balanceOf( vm.addr(fuji_privatekey) );
        console.log("Link balance: ", balance);

        console.log("msg.sender: ", msg.sender);
        console.log("messenger: ", address(messenger));
        console.log("fuji_privatekey: ", vm.addr(fuji_privatekey)); 
        console.log("this: ", address(this));

        vm.stopBroadcast();    
    }
}

contract DeployMessengerSepoliaScript is Script, Helper{  
    function run() public {
        uint256 sepolia_privatekey = vm.envUint("SEPOLIA_ACCOUNT_PRIVATE_KEY");

        vm.startBroadcast(sepolia_privatekey);
        Messenger messenger = new Messenger(routerEthereumSepolia , linkEthereumSepolia);

        console.log("Messenger deployed at address: ", address(messenger));
        console.log("\nPlease take note of the address.");
        
        console.log("\nDon't forget approve the Messenger contract to spend your LINK tokens.");

        vm.stopBroadcast();    
    }
}

contract initDriverFujiScript is Script, Helper{
    function run(address _messenger ) public {
        uint256 fuji_privatekey = vm.envUint("FUJI_ACCOUNT_PRIVATE_KEY");
        
        vm.startBroadcast(fuji_privatekey);
        Messenger messenger = Messenger(_messenger);

        messenger.start();

        address driver = messenger.getCCIPDriver();

        console.log("Driver initialized at address: ", driver);
        console.log("\nPlease take note of the address.");
        console.log("You will need it to add partners and send messages.");
    }
}


contract initDriverSepoliaScript is Script, Helper{
    function run(address _messenger ) public {
        uint256 sepolia_privatekey = vm.envUint("SEPOLIA_ACCOUNT_PRIVATE_KEY");
        
        vm.startBroadcast(sepolia_privatekey);
        Messenger messenger = Messenger(_messenger);

        messenger.start();

        address driver = messenger.getCCIPDriver();

        console.log("Driver initialized at address: ", driver);
        console.log("\nPlease take note of the address.");
        console.log("You will need it to add partners and send messages.");
    }
}


contract UpdateFujiPartnerScript is Script, Helper{  
    function run(address _messenger, address _partner ) public {
        uint256 fuji_privatekey = vm.envUint("FUJI_ACCOUNT_PRIVATE_KEY");

        vm.startBroadcast(fuji_privatekey);
        Messenger messenger = Messenger(_messenger);

        messenger.start();

        messenger.addPartner(_partner, chainIdEthereumSepolia);

        console.log("Partner added");

        vm.stopBroadcast();    
    }
}

contract UpdateSepoliaPartnerScript is Script, Helper{  
    function run(address _messenger, address _partner ) public {
        uint256 sepolia_privatekey = vm.envUint("SEPOLIA_ACCOUNT_PRIVATE_KEY");

        vm.startBroadcast(sepolia_privatekey);
        Messenger messenger = Messenger(_messenger);

        messenger.start();

        messenger.addPartner(_partner, chainIdAvalancheFuji);

        console.log("Partner added");

        vm.stopBroadcast();    
    }
}

contract SendMessageFujiScript is Script, Helper{  
    function run(address _messenger, address _receiver ) public {
        uint256 fuji_privatekey = vm.envUint("FUJI_ACCOUNT_PRIVATE_KEY");

        vm.startBroadcast(fuji_privatekey);
        Messenger messenger = Messenger(_messenger);

        messenger.start();

        bytes memory data = abi.encode("Hello Sepolia");

        messenger.sendMessage(chainIdEthereumSepolia, _receiver, data);

        console.log("Message sent");

        vm.stopBroadcast();    
    }
}