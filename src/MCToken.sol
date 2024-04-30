pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


contract MCToken is  ERC20, ERC20Burnable, AccessControl {
    constructor(address _payer, string memory _name, string memory _symbol) ERC20(_name, _symbol){
       bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
       bytes32 public constant RENT_DISTRIBUTOR = keccak256("RENT_DISTRIBUTOR");

       _grantRole(OPERATOR_ROLE, msg.sender);
       _grantRole(RENT_DISTRIBUTOR, payer)
    }    


}