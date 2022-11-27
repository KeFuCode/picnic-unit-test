// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "openzeppelin-contracts/utils/Strings.sol";

import "./AbstractERC1155Factory.sol";

/*
 * @title ERC1155 token for Picnic cards
 * @author kk-0xCreatorDao
 */
contract PicnicIdentity is AbstractERC1155Factory {
    event Minted(
        address indexed operator,
        address indexed to,
        uint256 indexed id,
        uint256 amount
    );
    event MintedBatch(
        address indexed operator,
        address indexed to,
        uint256[] ids,
        uint256[] amounts
    );

    constructor(
        string memory name,
        string memory symbol,
        string memory baseURI,
        address admin
    ) ERC1155(baseURI) {
        name_ = name;
        symbol_ = symbol;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    function sendIdentity(
        address to,
        uint256 id,
        uint256 amount
    ) external onlyRole(EXECUTOR_ROLE) {
        _mint(to, id, amount, "");
        emit Minted(msg.sender, to, id, amount);
    }

    function sendIdentityBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external onlyRole(EXECUTOR_ROLE) {
        _mintBatch(to, ids, amounts, "");
        emit MintedBatch(msg.sender, to, ids, amounts);
    }

    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public virtual override onlyRole(DEFAULT_ADMIN_ROLE) {
        _burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual override onlyRole(DEFAULT_ADMIN_ROLE) {
        _burnBatch(account, ids, values);
    }

    /**
     * @notice returns the metadata uri for a given id
     *
     * @param id the card id to return metadata for
     */
    function uri(uint256 id) public view override returns (string memory) {
        require(exists(id), "URI: nonexistent token");

        return string(abi.encodePacked(super.uri(id), Strings.toString(id)));
    }
}
