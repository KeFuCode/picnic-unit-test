// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "openzeppelin-contracts/access/AccessControl.sol";
import "openzeppelin-contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "openzeppelin-contracts/token/ERC1155/extensions/ERC1155Supply.sol";

abstract contract AbstractERC1155Factory is
    AccessControl,
    ERC1155Supply,
    ERC1155Burnable
{
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    string internal name_;
    string internal symbol_;

    function setURI(string memory baseURI)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
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

        require(from == address(0), "Picnic identity is not transferable");
        for (uint256 i = 0; i < ids.length; i++) {
            require(ids[i] != 0, "Token id can not be zero");
        }
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
