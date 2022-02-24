// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
contract NFT_1155 is ERC1155, Ownable {

                         //**** this portion is for transfer rewards to the minter ****//
    address RewardToken;
    address AddressERCTokenMinter;
    event RewardForMinting(address minter,address RewardTokenDeployerAddress, uint amount);
                                                //****  ****//

    constructor(address _RewardToken,address _AddressERCTokenMinter) ERC1155("") {
        RewardToken=_RewardToken;
        AddressERCTokenMinter=_AddressERCTokenMinter;
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)public {
        _mint(account, id, amount, data);
                              //** this is functionality for the transfer of reward to single minted token id **//
       IERC20(RewardToken).transferFrom(AddressERCTokenMinter,msg.sender,5);
       emit RewardForMinting(AddressERCTokenMinter,msg.sender,5);
                                  NFTMarket                        //****  ****//

    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)public onlyOwner {
        _mintBatch(to, ids, amounts, data);
                             //** this is functionality for the transfer of reward to multiple minted token id **//
         uint256 length=ids.length;
        IERC20(RewardToken).transferFrom(AddressERCTokenMinter,msg.sender,5*length);
        emit RewardForMinting(AddressERCTokenMinter,msg.sender,5*length);
                                                          //****  ****//
    }

   
}
