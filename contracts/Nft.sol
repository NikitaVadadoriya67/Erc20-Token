// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Nft {
    // Token details
    string public name;
    string public symbol;

    // NFT data
    // uint256 tokenId;
    string tokenURI;

    // mapping
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => address) public ownerOf;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(uint256 => uint256) price;
    mapping(uint256 => bool) isForSale;

    // Royalty info
    address public creator;
    address royaltyRecipient;
    uint256 royaltyPercentage = 500; // Basis points (500 = 5%)

    // Previous owners for royalty tracking
    address[] public previousOwners;
    mapping(address => mapping(uint256 => bool)) public isPreviousOwner;

    // Events
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );
    event RoyaltyPaid(address indexed recipient, uint256 amount);
    event PriceSet(uint256 newPrice, uint256 tokenId);
    event SaleStatusChanged(bool isForSale, uint256 tokenId);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        creator = msg.sender;
    }

     modifier onlyOwner(uint tokenId) {
        require(msg.sender == ownerOf[tokenId], "Only owner can call this");
        _;
    }

    function mint(
        address _to,
        uint256 _tokenId,
        string memory _ipfsHash,
        uint256 _initialPrice
    ) external {
        require(_to != address(0), "Mint to the zero address");
        require(ownerOf[_tokenId] == address(0), "Token already minted");

        balanceOf[_to] += 1; // set token id balance (for minting)
        ownerOf[_tokenId] = _to; // set token id owner
        royaltyRecipient = _to; // set recieved royalty address
        tokenURI = string(
            abi.encodePacked(
                "https://teal-large-mandrill-294.mypinata.cloud/ipfs/",
                _ipfsHash
            )
        ); // set token uri
        price[_tokenId] = _initialPrice; // set token initial sell price
        emit Transfer(address(0), _to, _tokenId);
    }

    // approve NFT 
    function _approve(address _to, uint256 _tokenId) internal {
        _tokenApprovals[_tokenId] = _to;
        emit Approval(ownerOf[_tokenId], _to, _tokenId);
    }

    // Transfer NFT without payment (owner only)
    function transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) external onlyOwner(_tokenId){
        require(
            ownerOf[_tokenId] == _from,
            "Transfer of token that is not own"
        );
        require(_to != address(0), "Cannot transfer to zero address");
        _approve(address(0), _tokenId);

        balanceOf[_from] -= 1;
        balanceOf[_to] += 1;
        ownerOf[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    // Get nft token all info
    function getNFTInfo(uint256 tokenId)
        external
        view
        returns (
            address currentOwner,
            string memory currentTokenURI,
            uint256 currentPrice,
            bool currentlyForSale,
            address royaltyReceiver,
            uint256 royaltyPercent
        )
    {
        return (
            ownerOf[tokenId],
            tokenURI,
            price[tokenId],
            isForSale[tokenId],
            royaltyRecipient,
            royaltyPercentage
        );
    }

    // Set price and sale status (owner only)
    function setPrice(uint256 _newPrice, uint256 tokenId) external onlyOwner(tokenId){
        price[tokenId] = _newPrice;
        emit PriceSet(_newPrice, tokenId);
    }

    function setSaleStatus(bool _isForSale, uint256 tokenId) external onlyOwner(tokenId) {
        isForSale[tokenId] = _isForSale;
        emit SaleStatusChanged(_isForSale, tokenId);
    }

    // buy nft function
    function buyNFT(uint256 tokenId) external payable {
        require(isForSale[tokenId], "NFT is not for sale");
        require(
            msg.sender != ownerOf[tokenId],
            "Owner cannot buy their own NFT"
        );
        require(
            msg.value >= price[tokenId],
            "Insufficient balance for buy NFT"
        );

        // Calculate royalty amount
        uint256 royaltyAmount = (msg.value * royaltyPercentage) / 10000;
        uint256 ownerAmount = msg.value - royaltyAmount;

        // Transfer funds
        payable(ownerOf[tokenId]).transfer(ownerAmount);
        payable(royaltyRecipient).transfer(royaltyAmount);

        // Transfer ownership
        address previousOwner = ownerOf[tokenId];
        _approve(msg.sender, tokenId);

        balanceOf[msg.sender] += 1;
        balanceOf[previousOwner] -= 1;
        ownerOf[tokenId] = msg.sender;

        emit Transfer(previousOwner, ownerOf[tokenId], tokenId);
        emit RoyaltyPaid(royaltyRecipient, royaltyAmount);
    }
}