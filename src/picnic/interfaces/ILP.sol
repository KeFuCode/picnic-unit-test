// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.9;

interface ILP {
    function sendLP(address _receiver, uint _amount) external;
    function burnLP(address _account, uint _amount) external;
    function balanceOf(address _account) external returns(uint);
}