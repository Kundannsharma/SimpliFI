// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20,Ownable {
    
    uint tokenPriceInWei=10;
    event BuyToken(address buyer, uint256 ethAmount, uint256 tokenAmount);


    constructor()  ERC20("MYTOKEN","MYTKN"){
     _mint(msg.sender, 100000 * (10 ** decimals()));

    }

    
    function setTokenPrice(uint256 newPrice) public onlyOwner {
        tokenPriceInWei = newPrice;
    }

    function buyTokens() public payable {
        require(msg.value > 0, "Send some Ether to buy tokens");
        address buyer = msg.sender;
        uint256 ethAmount = msg.value;
        uint256 tokenAmount = (ethAmount / tokenPriceInWei);

        _mint(msg.sender, tokenAmount * 10**18);


        emit BuyToken(buyer, ethAmount, tokenAmount);
    }

      function getTokenPrice() public view returns (uint256) {
        return tokenPriceInWei;
    }
}

//0x8047D171b62156A64bCa74E0372C7BBf935D7179