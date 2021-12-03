// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./ERC721Enumerable.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./IERC20.sol";



contract Buffalos is ERC721Enumerable, Ownable {

    using SafeMath for uint256;
    using Strings for uint256;

    // Time of when the sale starts.
    uint256 public blockStart;

    // Maximum amount of Buffalos in existance. 
    uint256 public MAX_SUPPLY;
    uint256 public cost;
    uint256 public maxSupply;
    uint256 public maxMintAmount;
    uint256 public BASE_RATE = 0.1 ether;
    uint public txFeeAmount;
    
    address public artist;
    address public txFeeToken;

    string public baseURI;
    string public nftName;
    string public nftUnit;
    string public uri;
    string public metaDataExt = ".json";

    bool public mintable = true;

    mapping(address => bool) public whitelisted;
    mapping(address => bool) public excludedList;

    event BuffaloBought (address buyer, uint256 amount);

    constructor(
        string memory name, 
        string memory symbol, 
        string memory URI,
        uint256 initialSupply, 
        uint256 startDate,
        address _artist,
        address _txFeeToken,
        uint _txFeeAmount
    ) ERC721(name, symbol) {
        setBaseURI(URI);
        setBlockStart(startDate);

        artist = _artist;
        txFeeToken = _txFeeToken;
        txFeeAmount = _txFeeAmount;
        excludedList[artist] = true;

        MAX_SUPPLY = initialSupply;        
        // Mint 30 Buffalos for airdrop and gift purposes
        for (uint i = 0; i < 1; i++) {
            uint mintIndex = totalSupply();
            _safeMint(msg.sender, mintIndex);
        }
    }

    // public
    function getNFTPrice(uint256 amount) public view returns (uint256) {
        // require(block.timestamp >= blockStart, "Sale has not started yet so you can't get a price yet.");
        // require(totalSupply() < MAX_SUPPLY, "Sale has already ended, no more Buffalos left to sell.");
        return amount.mul(BASE_RATE);
    }

    function setExcluded(address excluded, bool status) external {
        require(msg.sender == artist, 'artist only');
        excludedList[excluded] = status;
    }

    function setBlockStart(uint256 startDate) public {
        blockStart = startDate;
    }

    function updateBlockStart(uint256 startDate) public {
        require(block.timestamp <= blockStart, "Sale has already started.");
        blockStart = startDate;
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller isn't authorized");
        if(excludedList[from] == false) {
            _payTxFee(from);
        }
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        if(excludedList[from] == false) {
            _payTxFee(from);
        }
        safeTransferFrom(from, to, tokenId, '');
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller isn't authorized");
        if(excludedList[from] == false) {
            _payTxFee(from);
        }
        _safeTransfer(from, to, tokenId, _data);
    }

    function _payTxFee(address from) internal {
        IERC20 token = IERC20(txFeeToken);
        token.transferFrom(from, artist, txFeeAmount);
    }

    /**
    * @dev Mints yourself a Buffalo. Or more.
    */
    function mintBuffalo(uint256 numberofBuffalos) public payable {
        // Some exceptions that need to be handled.
        require(block.timestamp >= blockStart, "Sale has not started yet so you can't get a price yet.");
        require(totalSupply() < MAX_SUPPLY, "Sale has already ended.");
        require(numberofBuffalos > 0, "You cannot mint 0 Buffalos.");
        require(SafeMath.add(totalSupply(), numberofBuffalos) <= MAX_SUPPLY, "Exceeds maximum Buffalos supply. Please try to mint less Buffalos.");
        // require(getNFTPrice(numberofBuffalos) <= msg.value, "Amount of Ether sent is not correct.");
        require(getNFTPrice(numberofBuffalos) <= balanceOf(msg.sender), "Amount of Token is not sufficient.");

        // Mint the amount of provided Ladies.
        for (uint i = 0; i < numberofBuffalos; i++) {
            uint mintIndex = totalSupply();
            _safeMint(msg.sender, mintIndex);
        }
        IERC20 token = IERC20(txFeeToken);
        token.approve(msg.sender, getNFTPrice(numberofBuffalos));
        token.transferFrom(msg.sender, artist, getNFTPrice(numberofBuffalos));

        emit BuffaloBought (msg.sender, numberofBuffalos);
    }

    /**
    * @dev Withdraw ether from this contract (Callable by owner only)
    */
    
    function canMint(bool mintFlag) onlyOwner public {
        mintable = mintFlag;
    }

    function withdraw(uint256 amount) onlyOwner public {
        payable(msg.sender).transfer(amount);
    }

    /**
    * @dev Changes the base URI if we want to move things in the future (Callable by owner only)
    */
    function changeBaseURI(string memory URI) onlyOwner public {
       setBaseURI(URI);
    }
    /**
    * @dev Changes max supply based on future drop dates (owner only)
    */
    function changeMaxSupply(uint256 supply) onlyOwner public {
        MAX_SUPPLY = supply;
    }

    function updateMintPrice(uint256 price) onlyOwner public {
        BASE_RATE = price;
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
        _exists(tokenId),
        "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), metaDataExt))
            : "";
    }

    //only owner
    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) onlyOwner public {
        maxMintAmount = _newmaxMintAmount;
    }

    function setBaseURI(string memory _newBaseURI) onlyOwner public {
        baseURI = _newBaseURI;
    }

    function whitelistUser(address _user) onlyOwner public {
        whitelisted[_user] = true;
    }

    function removeWhitelistUser(address _user) onlyOwner public {
        whitelisted[_user] = false;
    }

}