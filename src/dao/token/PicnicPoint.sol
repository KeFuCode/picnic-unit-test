// SPDX-License-Identifier: MIT
pragma solidity =0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/*
 * @title No-transfer ERC20 token for Picnic points
 * @author kk-0xCreatorDao
 */
contract PicnicPoint is ERC20, Ownable {
    event Minted(address indexed operator, address indexed to, uint256 amount);

    // Picnic Point, PP
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    // temporary test function: The deploy version will be deleted.
    function testMint(uint256 amount) external {
        _mint(msg.sender, amount);
    }

    function sendToken(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
        emit Minted(msg.sender, to, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from == address(0), "Err: token transfer is BLOCKED");
        super._beforeTokenTransfer(from, to, amount);
    }
}