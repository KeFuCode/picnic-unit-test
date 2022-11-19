// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "openzeppelin-contracts/utils/Strings.sol";
import "openzeppelin-contracts/access/AccessControl.sol";

import "./AbstractERC1155Factory.sol";

/*
 * @title ERC1155 token for Picnic cards
 * @author kk-0xCreatorDao
 */
contract PicnicIdentity is AbstractERC1155Factory, AccessControl {
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    address[] private executors;
    mapping(address => bool) public isExecutor;
    mapping(address => uint) private executorIndex;

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

        executors.push(address(0));
    }

    // temporary test function: The deploy version will be deleted.
    function testMint(uint256 id, uint256 amount) external {
        _mint(msg.sender, id, amount, "");
    }

    // =================== executor ===================

    function setExecutor(address account) external onlyOwner {
        require(
            isExecutor[account] == false,
            "The account is already the executor."
        );

        _addExecutor(account);
        grantRole(EXECUTOR_ROLE, account);
    }

    function revokeExecutor(address account) external onlyOwner {
        require(
            isExecutor[account] == true,
            "The account is not the executor."
        );

        _deleteExecutor(account);
        revokeRole(EXECUTOR_ROLE, account);
    }

    function getExecutors() external view returns (address[] memory) {
        return executors;
    }

    function _addExecutor(address account) private {
        isExecutor[account] = true;
        if (_checkExecutor(account)) {
            executors[executorIndex[account]] = account;
        } else {
            executors.push(account);
            executorIndex[account] = executors.length - 1;
        }
    }

    function _deleteExecutor(address account) private {
        isExecutor[account] = false;
        delete executors[executorIndex[account]];
    }

    function _checkExecutor(address account) private view returns (bool) {
        if (executorIndex[account] != 0) {
            return true;
        } else {
            return false;
        }
    }

    // =================== nft ========================

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
    ) public virtual override onlyOwner {
        _burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual override onlyOwner {
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
