// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import "openzeppelin-contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "openzeppelin-contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces/ILPUpgradeable.sol";

contract PoolUpgradeable is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public LP;
    address public TokenAddress;

    // ============ Methods ============

    constructor() {
        _disableInitializers();
    }

    function initialize(address _LP, address _tokenAddress) public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();

        LP = _LP;
        TokenAddress = _tokenAddress;
    }

    function withdrawFunds(uint256 _amount) external {
        require(LP != address(0), "Insufficient LP address");
        require(
            ILPUpgradeable(LP).balanceOf(msg.sender) >= _amount,
            "LP balance is not enough."
        );
        ILPUpgradeable(LP).burnLP(msg.sender, _amount);
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
        require(TokenAddress != address(0), "Insufficient token address");
        require(
            IERC20Upgradeable(TokenAddress).balanceOf(address(this)) >= _amount,
            "Insufficient balance to send"
        );
        IERC20Upgradeable(TokenAddress).safeTransfer(_receiver, _amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
}
