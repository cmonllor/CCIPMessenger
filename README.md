## CCIP Messenger

** CCIP Messenger & CCDPDriver: a Driver for CCIP and a Crosschain Messenger as a simplest usecase. **

CCIP Messenger consists of:

-   **CCIP Messenger**: Contract that instantiates CCIPDriver and implements ICCIPDriverConsumer
-   **CCIPDriver**: Driver for CCIP
-   **CCIPMessenger Script**: *Forge* script with contracts to implement and interact

CCIP Driver is generic and can be used in any context wich requires complex cross-chain data communication.

CCIP Messenger is also generic, but CCIPMessengerScript.s.sol contracts use hardcoded values as a PoC. In this case it's implemented in **Avalanche Fuji Testnet** and **Ethereum Seppolia Testnet**.

## Usage

### Build

```shell
$ npm install
$ forge install
```

### Test

```shell
$ forge test
```

### Deploy

## Update .env

First we must create our **.env** file.

```.env
FUJI_ACCOUNT_PRIVATE_KEY = <your_fuji_account_private_key>
FUJI_RPC_URL = <your_fuji_rpc>

SEPOLIA_ACCOUNT_PRIVATE_KEY = <your_sepolia_private_key>
SEPOLIA_RPC_URL = <your_sepolia_rpc>
```
TODO: use this .env so I stop sharing my RPC endpoints in foundry.toml and do things f****g right

Be sure you have founded both accounts with LINK testnet token and native token for gas and fees. 

## Deploy contracts

Now we can deploy our contracts. Srcipts are hardcoded and use contract Helper.sol from https://github.com/smartcontractkit/ccip-starter-kit-foundry/blob/main/script/Helper.sol hardcoded values.

** Avalanche Fuji testnet **
```shell
$ forge script script/CCIPMessenger.s.sol:DeployMessengerFujiScript -vvv --rpc-url <your_rpc_url> 
```

** Ethereum Seppolia testnet **
```shell
$ forge script script/CCIPMessenger.s.sol:DeployMessengerSepoliaScript -vvv --rpc-url <your_rpc_url> 
```

Be sure you take note of transaction hashes and contract addresses for further analisys and inspection.

## Fund contracts

Each Messenger contract should be funded with some LINK. Please refer to https://docs.chain.link/resources/link-token-contracts to get both LINK and native tokens for any testnet you may be using. 

## Add partner data

Deterministic address deployment has not been (still) implemented here, so in coding time Messenger addresses weren't available for fast hardcoding, so information about each other contract must be updated manually.


```shell
$ forge script script/CCIPMessenger.s.sol:UpdateFujiPartnerScript -vvv  \ 
     --rpc-url <your_rpc_url> --sig "run(address,address)" \
     --  <your_fuji_messenger_address> <your_sepolia_messenger_address>
```

```shell
$ forge script script/CCIPMessenger.s.sol:UpdateSepoliaPartnerScript -vvv  \ 
     --rpc-url <your_rpc_url> --sig "run(address,address)" \
     --  <your_sepolia_messenger_address> <your_fuji_messenger_address>
```

