pragma solidity ^0.8.7;

import "solmate/tokens/ERC20.sol";

contract FakeUSDC is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _amount
    ) ERC20(_name, _symbol, _decimals) {
        _mint(msg.sender, _amount);
    }
}
