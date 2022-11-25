// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.7;

import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-contracts/access/Ownable.sol";

import "./interfaces/ILP.sol";

contract Pool is Ownable {
    using SafeERC20 for IERC20;

    // ============ Storage ============

    address public LP;
    address public TokenAddress;

    // ============ Methods ============

    constructor(address _LP, address _tokenAddress) {
        LP = _LP;
        TokenAddress = _tokenAddress;
    }

    function withdrawFunds(uint _amount) external {
        require(
            ILP(LP).balanceOf(msg.sender) >= _amount,
            "Must have enough LP Token."
        );
        ILP(LP).burnLP(msg.sender, _amount);
        _sendFunds(msg.sender, _amount);
    }

    function setLP(address _lp) external onlyOwner {
        LP = _lp;
    }

    function setTokenAddress(address _tokenAddress) external onlyOwner {
        TokenAddress = _tokenAddress;
    }

    // ============ Private Methods ============

    function _sendFunds(address _receiver, uint256 _amount) private {
        require(
            IERC20(TokenAddress).balanceOf(address(this)) >= _amount,
            "Insufficient balance to send"
        );
        IERC20(TokenAddress).safeTransfer(_receiver, _amount);
    }
}
