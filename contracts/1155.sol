// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
pragma experimental ABIEncoderV2 ;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

contract Medal is ERC1155, ERC1155Pausable, ERC1155Burnable, AccessControlEnumerable {
    
    using Strings for uint256;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    
    uint public totalMedals;
    string public baseURI;
    string public name; 
    string public symbol;
    
    mapping (uint256 => uint256) public _tokenSupply;

    event ChangeMedalTypes(uint _totalMedalType);
    
    modifier validTokenId(uint256 _id){
        require(
            _id > 0 && _id <= totalMedals,
            "Medal: not a valid medal id "
        );
        _;
    }
    
    constructor(
        string memory _baseURI,
        uint _totalMedalType, 
        address _minter,
        address _burner,
        address _pauser) ERC1155(_baseURI) {
        name = "Medal";
        symbol = "MDL";
        _setURI(_baseURI);
        totalMedals = _totalMedalType;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _minter);
        _setupRole(BURNER_ROLE, _burner);
        _setupRole(PAUSER_ROLE, _pauser);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControlEnumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Pausable) {}

    function changeMedalTypes(uint _totalMedalType) external onlyRole(DEFAULT_ADMIN_ROLE){
        require(
            _totalMedalType != totalMedals,
            "Medal: _totalMedalType must be different"
        );
        totalMedals = _totalMedalType;
        emit ChangeMedalTypes(_totalMedalType);
    }
    
    function _setURI(string memory _newuri) internal override {
        baseURI = _newuri;
    }
    
    function uri(uint256 _tokenId) public view override returns (string memory) {
        require(
            _exists(_tokenId), 
            "Medal: URI query for nonexistent token"
        );
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, _tokenId.toString(),".json")) : "";
    }

    function dropMedal(address[] memory _addresses,uint256[] memory  _quantities,uint256 _id) external whenNotPaused(){
        require(
            _addresses.length == _quantities.length,
            "Medal: both array are not equal"
        );
        for (uint256 i = 0; i < _addresses.length; i++) {
           mint(_addresses[i],_id,_quantities[i]); 
        }
    }

    function mint(address _to,uint256 _id,uint256 _quantity) public onlyRole(MINTER_ROLE) validTokenId(_id) whenNotPaused(){
        require(
            _to != address(0),
            "Medal: enter valid address"
        );
        require(
            _quantity >0,
            "Medal: quantity must be greater than zero"
        );
        _mint(_to, _id, _quantity,"");
        _tokenSupply[_id] = _tokenSupply[_id] + _quantity;
    }

    function batchMint(address _to,uint256[] memory _ids,uint256[] memory _quantities) external onlyRole(MINTER_ROLE) whenNotPaused(){
        require(
            _to != address(0),
            "Medal: enter valid address"
        );
        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 _id = _ids[i];
            require(
                _id <= totalMedals && _id > 0,
                "Medal: not a valid medal Id"
            );
            uint256 quantity = _quantities[i];
            require(
                quantity >0,
                "Medal: quantity must be greater than zero"
            );
            _tokenSupply[_id] = _tokenSupply[_id] + quantity;
        }
        _mintBatch(_to, _ids, _quantities,"");
    }
    
    function burn(address _account,uint256 _id,uint256 _amount) public override validTokenId(_id) onlyRole(BURNER_ROLE) whenNotPaused(){
        require(
            msg.sender == _account || isApprovedForAll(_account,msg.sender),
            "Medal: caller is not owner nor approved"
        );
        require(
            _amount >0,
            "Medal: _amount must be greater than zero"
        );
        require(
            _tokenSupply[_id] >= _amount,
            "Medal: not a valid amount"
        );
        _tokenSupply[_id] = _tokenSupply[_id] - _amount;
        _burn(_account,_id,_amount);
    }

    function batchBurn(address _account,uint256[] memory _ids,uint256[] memory _quantities) external onlyRole(BURNER_ROLE) whenNotPaused(){
        require(msg.sender == _account || isApprovedForAll(_account,msg.sender),"Medal: caller is not owner nor approved");
        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 _id = _ids[i];
            require(
                _id <= totalMedals && _id > 0,
                "Medal: not a valid Id"
            );
            uint256 quantity = _quantities[i];
            require(
                quantity >0,
                "Medal: quantity must be greater than zero"
            );
            require(
                _tokenSupply[_id] >= quantity,
                "Medal: not a valid amount"
            );
            _tokenSupply[_id] = _tokenSupply[_id] - quantity;
        }
        _burnBatch(_account,_ids,_quantities);
    }

    function pause() public onlyRole(PAUSER_ROLE) whenNotPaused {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) whenPaused {
        _unpause();
    }
    
    function _exists(uint256 _id) internal view returns (bool) {
        return _tokenSupply[_id] != 0;
    }
    
}