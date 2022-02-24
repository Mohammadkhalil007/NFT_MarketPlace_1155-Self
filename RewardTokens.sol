// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ERC20.sol";
contract RewardTokens is ERC20{
     function minting()public {
         _mint(msg.sender, 5000);
     }
}
