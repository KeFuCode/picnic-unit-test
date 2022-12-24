// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "openzeppelin-contracts/utils/Strings.sol";

import "./AbstractERC1155Factory.sol";

/*
 * @title ERC1155 token for Picnic Identity
 * @author kk-0xCreatorDao
 */
contract PicnicIdentity is AbstractERC1155Factory {
    event MemberGetIdentity(
        address indexed operator,
        address indexed to,
        uint256 id,
        uint256 amount
    );
    event MemberGetIdentities(
        address indexed operator,
        address indexed to,
        uint256[] ids,
        uint256[] amounts
    );
    event MembersGetIdentity(
        address indexed operator,
        address[] indexed tos,
        uint256 id,
        uint256 amount
    );

    event BurnMemberIdenetity(
        address indexed operator,
        address indexed account,
        uint256 id,
        uint256 amount
    );
    event BurnMemberIdenetities(
        address indexed operator,
        address indexed account,
        uint256[] ids,
        uint256[] amounts
    );
    event BurnMembersIdenetity(
        address indexed operator,
        address[] indexed accounts,
        uint256 id,
        uint256 amount
    );

    // 0xCreator Identity, 0CI
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

    function sendMemberIdentity(
        address to,
        uint256 id,
        uint256 amount
    ) external onlyRole(EXECUTOR_ROLE) {
        _mint(to, id, amount, "");
        emit MemberGetIdentity(msg.sender, to, id, amount);
    }

    function sendMemberIdentities(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external onlyRole(EXECUTOR_ROLE) {
        _mintBatch(to, ids, amounts, "");
        emit MemberGetIdentities(msg.sender, to, ids, amounts);
    }

    function sendMembersIdentity(
        address[] memory tos,
        uint256 id,
        uint256 amount
    ) external onlyRole(EXECUTOR_ROLE) {
        for (uint256 i = 0; i < tos.length; i++) {
            _mint(tos[i], id, amount, "");
        }
        emit MembersGetIdentity(msg.sender, tos, id, amount);
    }

    function burn(
        address account,
        uint256 id,
        uint256 amount
    ) public virtual override onlyRole(DEFAULT_ADMIN_ROLE) {
        _burn(account, id, amount);
        emit BurnMemberIdenetity(msg.sender, account, id, amount);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public virtual override onlyRole(DEFAULT_ADMIN_ROLE) {
        _burnBatch(account, ids, amounts);
        emit BurnMemberIdenetities(msg.sender, account, ids, amounts);
    }

    function burnMembersIdentity(
        address[] memory tos,
        uint256 id,
        uint256 amount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 i = 0; i < tos.length; i++) {
            _burn(tos[i], id, amount);
        }
        emit BurnMembersIdenetity(msg.sender, tos, id, amount);
    }

    function setExecutor(address executor, bool enabled) external {
        if (enabled) {
            grantRole(EXECUTOR_ROLE, executor);
        } else {
            revokeRole(EXECUTOR_ROLE, executor);
        }
    }

    function isExecutor(address account) public view returns (bool) {
        return hasRole(EXECUTOR_ROLE, account);
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
