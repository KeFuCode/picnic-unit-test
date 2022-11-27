// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

interface ILPUpgradeable {
    function sendLP(address _receiver, uint256 _amount) external;

    function burnLP(address _account, uint256 _amount) external;

    function balanceOf(address _account) external returns (uint256);
}
