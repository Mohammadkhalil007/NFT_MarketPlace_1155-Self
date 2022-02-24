// contracts/Market.sol
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/IERC1155.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
contract NFTMarket is ReentrancyGuard {
  using Counters for Counters.Counter;
  Counters.Counter private _itemIds;
  Counters.Counter private _itemsSold;
  address payable owner;
  uint256 listingPrice = 0.000000000000000025 ether;

  address NFT1155_Contract;
  address OwnerOf1155;
  constructor(address _NFT1155_Contract,address _OwnerOf1155) {
    NFT1155_Contract=_NFT1155_Contract;
    OwnerOf1155=_OwnerOf1155;
    owner = payable(msg.sender);
  }

                                           //*******************Auction*****************//
    bool public started;
    uint public endAt;
    event Start();
    bool public ended;
    uint public HighestBid;
    address public highBider;
    uint public __price;

    event End(address highBider, uint HighestBid);
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);
    mapping (address => uint) recordOfBider;

   
                                              //**************************************//

  struct MarketItem {
    uint itemId;
    address NFT_1155_Contract;
    uint256 tokenId;
    address payable seller;
    address payable owner;
    uint256 price;
    bool sold;
  }

  mapping(uint256 => MarketItem) private idToMarketItem;
  event MarketItemCreated (uint indexed itemId,address indexed nftContract,uint256 indexed tokenId,address seller,address owner,uint256 price,bool sold);
      
                                           //***************** Auction Start******************//
        function start() public  {
         require (!started,"already started");
         require (msg.sender == owner, "you can not start the auction");
          started=true;
          endAt= block.timestamp + 1 minutes;
          emit Start();
     }

                                             //***************** Auction End******************//
        function end() public {
        require(started, "first need to start");
        require(block.timestamp >= endAt, "Auction is still ongoing");
        require(!ended ,"Auction already ended");
        ended=true;  
        emit End(highBider,HighestBid);    

    } 

  /* Returns the listing price of the contract */
  function getListingPrice() public view returns (uint256) {
    return listingPrice;
  }

  /* Places an item for sale on the marketplace */
  function ListYourNFT(uint256 tokenId,uint256 price) public payable nonReentrant {
    __price=price;
    require(price > 0, "Price must be at least 1 wei");
    require(msg.value == listingPrice, "Please Pay the fees of Markeplace");
    _itemIds.increment();
    uint256 itemId = _itemIds.current();
    idToMarketItem[itemId] =  MarketItem(itemId,NFT1155_Contract,tokenId,payable(msg.sender),payable(address(0)),price,false);
    //*** calling function of ERC1155 ***//
    // IERC1155(NFT1155_Contract).setApprovalForAll(address(this),true);
    emit MarketItemCreated(itemId,NFT1155_Contract,tokenId,msg.sender,address(0),price,false);
  }
    
         //***************** Auction Biding******************//
        function bid()public payable{
         require(msg.value > __price, "Please start biding greater the NFT price to Purchase it ");
         require(started,"Not Started Yet");
         require(block.timestamp < endAt, "Ended");
         require(msg.value >= HighestBid);
         if(highBider !=address(0)){
             recordOfBider[highBider] +=HighestBid;
         }
         HighestBid=msg.value;
         highBider=msg.sender;
         emit Bid(highBider, HighestBid);
     }

  /* Creates the sale of a marketplace item */
  /* Transfers ownership of the item, as well as funds between parties */
  function PurchaseNFT(uint256 itemId) public payable nonReentrant {
    uint price = idToMarketItem[itemId].price;
    uint tokenId = idToMarketItem[itemId].tokenId;
    require(msg.value == HighestBid, "Please submit the asking price in order to complete the purchase");
    idToMarketItem[itemId].seller.transfer(msg.value);
    IERC1155(NFT1155_Contract).safeTransferFrom(OwnerOf1155,msg.sender,tokenId, price,"0x00");
    idToMarketItem[itemId].owner = payable(msg.sender);
    idToMarketItem[itemId].sold = true;
    _itemsSold.increment();
    payable(owner).transfer(listingPrice);
  }

  /* Returns all unsold market items */
  function fetchMarketItems() public view returns (MarketItem[] memory) {
    uint itemCount = _itemIds.current();
    uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
    uint currentIndex = 0;
    MarketItem[] memory items = new MarketItem[](unsoldItemCount);
    for (uint i = 0; i < itemCount; i++) {
      if (idToMarketItem[i + 1].owner == address(0)) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /* Returns only items that a user has purchased */
  function fetchMyNFTs() public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /* Returns only items a user has created */
  function fetchItemsCreated() public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == msg.sender) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }
}
