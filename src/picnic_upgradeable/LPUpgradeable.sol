// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import "openzeppelin-contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract LPUpgradeable is
    Initializable,
    ERC20Upgradeable,
    OwnableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant SALES_ROLE = keccak256("SALES_ROLE");
    bytes32 public constant POOL_ROLE = keccak256("POOL_ROLE");

    event IncreaseLP(address indexed account, uint256 indexed amount);
    event DecreaseLP(address indexed account, uint256 indexed amount);

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _sales,
        address _pool,
        address _admin
    ) public initializer {
        __ERC20_init("Picnic Profit", "PP");
        __Ownable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(SALES_ROLE, _sales);
        _grantRole(POOL_ROLE, _pool);
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function sendLP(address _receiver, uint256 _amount)
        external
        onlyRole(SALES_ROLE)
    {
        _mint(_receiver, _amount);

        emit IncreaseLP(_receiver, _amount);
    }

    function burnLP(address _account, uint256 _amount)
        external
        onlyRole(POOL_ROLE)
    {
        _burn(_account, _amount);

        emit DecreaseLP(_account, _amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
}
