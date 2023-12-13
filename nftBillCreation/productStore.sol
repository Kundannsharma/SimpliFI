// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ProductStore is ERC721, Ownable {
    IERC20 public token; // ERC20 token contract

    using Counters for Counters.Counter;
    Counters.Counter private _billIds;

    event BuyProduct(address indexed buyer, uint256 productId, uint256 amountPaid);

    struct Product {
        uint256 id;
        string name;
        uint256 price;
    }

    mapping(uint256 => Product) public products;
    mapping(address => uint256[]) public userPurchases;

    uint256 public nextProductId;

    constructor(address _tokenAddress) ERC721("ProductBill", "PBL") {
        token = IERC20(_tokenAddress);
    }

    function addProduct(string memory _name, uint256 _price) external onlyOwner {
        uint256 productId = nextProductId++;
        products[productId] = Product(productId, _name, _price);
    }

    function buyProduct(uint256 _productId) external {
        Product storage product = products[_productId];
        require(product.id != 0, "Product does not exist");
        require(token.transferFrom(msg.sender, address(this), product.price*10**18), "Token transfer failed");

        // whenever user buy a product then unique nft bill is created with uinique id
        uint256 billId = _billIds.current();
        _safeMint(msg.sender, billId);

        _billIds.increment();

        // Record the purchase for the user
        userPurchases[msg.sender].push(_productId);

        emit BuyProduct(msg.sender, _productId, product.price);
    }

    function getUserProductDetails(address user) external view returns (Product[] memory) {
        uint256[] memory purchasedProductIds = userPurchases[user];
        Product[] memory userDetails = new Product[](purchasedProductIds.length);

        for (uint256 i = 0; i < purchasedProductIds.length; i++) {
            uint256 productId = purchasedProductIds[i];
            userDetails[i] = products[productId];
        }

        return userDetails;
    }
}
 