// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import "solmate/tokens/ERC20.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/access/AccessControl.sol";

contract LP is ERC20, Ownable, AccessControl {
    bytes32 public constant SALES_ROLE = keccak256("SALES_ROLE");
    bytes32 public constant POOL_ROLE = keccak256("POOL_ROLE");

    event IncreaseLP(address indexed account, uint256 indexed amount);
    event DecreaseLP(address indexed account, uint256 indexed amount);

    constructor(
        address _sales,
        address _pool,
        address _admin
    ) ERC20("LP Token", "LP", 6) {
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
}
