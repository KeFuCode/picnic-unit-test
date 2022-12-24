// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";

abstract contract AbstractERC1155Upgradeable is
    ERC1155SupplyUpgradeable,
    OwnableUpgradeable
{
    string internal name_;
    string internal symbol_;

    function __AbstractERC1155_init() internal onlyInitializing {}

    function __AbstractERC1155_init_unchained() internal onlyInitializing {}

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
    ) internal virtual override(ERC1155SupplyUpgradeable) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        for (uint256 i = 0; i < amounts.length; i++) {
            uint256 amount = amounts[i];
            require(amount > 0, "Transfer amount is zero");
        }
    }
}
