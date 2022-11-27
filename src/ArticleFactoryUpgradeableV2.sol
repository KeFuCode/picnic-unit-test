pragma solidity ^0.8.10;

import "./picnic_upgradeable/ArticleFactoryUpgradeable.sol";

contract ArticleFactoryUpgradeableV2 is ArticleFactoryUpgradeable {
    uint256 public x;
    uint256 public y;

    function setX(uint256 _x) public {
        x = _x;
    }

    function setY(uint256 _y) public {
        y = _y;
    }
}
