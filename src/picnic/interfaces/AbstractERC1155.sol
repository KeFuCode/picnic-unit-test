// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "openzeppelin-contracts/token/ERC1155/extensions/ERC1155Supply.sol";

abstract contract AbstractERC1155 is
    ERC1155Supply,
    ERC1155Burnable,
    Ownable
{
    string internal name_;
    string internal symbol_;

    function setURI(string memory baseURI) external onlyOwner {
        _setURI(baseURI);
    }

    function name() public view returns (string memory) {
        return name_;
    }

    function symbol() public view returns (string memory) {
        return symbol_;
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        for (uint i = 0; i < amounts.length; i++) {
            uint amount = amounts[i];
            require(amount > 0, "Transfer amount is zero");
        }
    }
}
