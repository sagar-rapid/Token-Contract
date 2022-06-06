// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyNFT is ERC721, ERC721Pausable, ERC721Burnable, AccessControlEnumerable, ERC721URIStorage{

    using Strings for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    uint256 constant public BASE_TEMPLATE_ID = 1000000;

    mapping(address => EnumerableSet.UintSet) private _holderTokens;
    mapping(uint256 => uint256) counters;
    string private baseURI_;

    constructor(string memory _baseTokenURI, address _minter, address _burner, address _pauser) ERC721("MyNFT", "MNFT") {
        _setBaseURI(_baseTokenURI);
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _minter);
        _setupRole(BURNER_ROLE, _burner);
        _setupRole(PAUSER_ROLE, _pauser);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControlEnumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) 
    internal 
    override (ERC721, ERC721Pausable) {

        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _setBaseURI(string memory _baseTokenURI) internal {
        baseURI_ = _baseTokenURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI_;
    }

    function tokenURI(uint256 tokenId) 
        public 
        view 
        override(ERC721, ERC721URIStorage) 
        returns (string memory) {
        require(_exists(tokenId), "NFT4Play: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function mint(address _to, uint256 _nftType) public onlyRole(MINTER_ROLE) whenNotPaused(){
        require(_to != address(0),"MyNNFT: _to address not valid");
        counters[_nftType]++;
        uint256 tokenId = _nftType * BASE_TEMPLATE_ID + counters[_nftType];
        _holderTokens[_to].add(tokenId);
        _safeMint(_to,tokenId);
    }

    function batchMint(address _to, uint256 _nftType, uint256 _numberOfTokens) external  onlyRole(MINTER_ROLE) whenNotPaused(){
        for (uint256 i = 0; i < _numberOfTokens; i++) {
            mint(_to, _nftType);
        }
    }

    function burn(uint _tokenId) public override onlyRole(BURNER_ROLE) whenNotPaused(){
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "MyNFT: burn caller is not owner nor approved");
        _holderTokens[msg.sender].remove(_tokenId);
        _burn(_tokenId);
    }

    function pause() public onlyRole(PAUSER_ROLE) whenNotPaused {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) whenPaused {
        _unpause();
    }

    function getTokens(address _address) external view returns(uint256[] memory){
        return _holderTokens[_address].values();
    }
}