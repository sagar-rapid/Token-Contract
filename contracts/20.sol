// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";

contract Token is Ownable, Pausable, ERC20{
    uint public constant MAX_SUPPLY = 100 * 10**6 * 10**18;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
    }
    
    function mint(address to, uint256 amount) public virtual onlyOwner whenNotPaused{
        uint newTotalSupply = totalSupply() + amount;
        require(newTotalSupply <= MAX_SUPPLY,"Token: New Total Supply exceeds Max Limit");
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public virtual onlyOwner whenNotPaused{
        uint newTotalSupply = totalSupply() - amount;
        require(newTotalSupply >= 0,"Token: New Total Supply preceeds lower limit");
        _burn(from, amount);
    }

    function pause() public virtual onlyOwner whenNotPaused{
        require(!paused(),"Token: Already paused");
        _pause();
    }

    function unpause() public virtual onlyOwner whenPaused{
        require(paused(),"Token: Already not paused");
        _unpause();
    }
}