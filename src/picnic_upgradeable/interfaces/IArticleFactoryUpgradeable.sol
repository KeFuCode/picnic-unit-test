// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.7;

interface IArticleFactoryUpgradeable {
    function mint(
        address receiver,
        uint256 id,
        uint256 amount
    ) external;

    function mintBatch(
        address receiver,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external;

    function createArticle(
        bytes20 uid,
        uint tokenId,
        address author,
        uint price,
        uint32 numMax,
        uint32 authorBPS,
        uint32 sharerBPS
    ) external;
}
