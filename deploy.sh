#!/bin/bash
source "$HOME/.bashrc"

forge script  --rpc-url fuji --broadcast script/CCIPMessenger.s.sol:DeployMessengerFujiScript  


echo "Type or paste the Fuji Messenger Address"
read FUJI_MESSENGER_ADDRESS
export FUJI_MESSENGER_ADDRESS

forge script  --rpc-url sepolia --broadcast  script/CCIPMessenger.s.sol:DeployMessengerSepoliaScript 

echo "Type or paste the Sepolia Messenger Address"
read SEPOLIA_MESSENGER_ADDRESS
export SEPOLIA_MESSENGER_ADDRESS

npm run approvals

forge script --rpc-url fuji --broadcast --sig "run(address)" \
        script/CCIPMessenger.s.sol:initDriverFujiScript  -- \
        $FUJI_MESSENGER_ADDRESS

echo "Type or paste the Fuji CCIPDriver Address"
read FUJI_CCIPDRIVER_ADDRESS
export FUJI_CCIPDRIVER_ADDRESS

forge script --rpc-url sepolia --broadcast --sig "run(address)" \
        script/CCIPMessenger.s.sol:initDriverSepoliaScript  -- \
        $SEPOLIA_MESSENGER_ADDRESS

echo "Type or paste the Sepolia CCIPDriver Address"
read SEPOLIA_CCIPDRIVER_ADDRESS
export SEPOLIA_CCIPDRIVER_ADDRESS

forge script --rpc-url fuji --broadcast --sig "run(address,address)" \
        script/CCIPMessenger.s.sol:UpdateFujiPartnerScript -- \
        $FUJI_MESSENGER_ADDRESS $FUJI_CCIPDRIVER_ADDRESS

forge script --rpc-url sepolia --broadcast --sig "run(address,address)" \
        script/CCIPMessenger.s.sol:UpdateSepoliaPartnerScript -- \
        $SEPOLIA_MESSENGER_ADDRESS $SEPOLIA_CCIPDRIVER_ADDRESS

