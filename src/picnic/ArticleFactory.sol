// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.7;

import "openzeppelin-contracts/access/AccessControl.sol";

import "./interfaces/AbstractERC1155.sol";

// This contract is a combination of Mirror.xyz's Articles.sol and Soundxyz's Artist.sol

/**
 * @title ArticleFactory
 * @author kk-0xCreatorDao
 */
contract ArticleFactory is AbstractERC1155, AccessControl {
    // ============ Structs ============
    struct Article {
        address author;
        uint32 numSold;
        uint32 numMax;
    }

    // ============ Storage ============
    bytes32 public constant SALES_ROLE = keccak256("SALES_ROLE");

    // Mapping of Article id to descriptive data. Article id = Token id.
    mapping(uint => Article) public articles;
    // Mapping of author address to Article id.
    mapping(address => uint[]) public authorToArticles;

    // ============ Events ============

    event ArticleCreated(
        bytes20 indexed uid,
        uint indexed tokenId,
        address indexed author,
        uint price,
        uint32 numMax,
        uint32 authrorBPS,
        uint32 sharerBPS
    );

    event ArticleMinted(
        address indexed buyer,
        uint indexed tokenId,
        uint indexed amount
    );

    event ArticleMintedBatch(
        address indexed buyer,
        uint[] indexed tokenIds,
        uint[] indexed amounts
    );

    // ============ Methods ============

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        address _admin
    ) ERC1155(_uri) {
        name_ = _name;
        symbol_ = _symbol;

        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function createArticle(
        bytes20 _uid,
        uint _tokenId,
        address _author,
        uint _price,
        uint32 _numMax,
        uint32 _authorBPS,
        uint32 _sharerBPS
    ) external onlyRole(SALES_ROLE) {
        articles[_tokenId] = Article({
            author: _author,
            numSold: 0,
            numMax: _numMax
        });

        authorToArticles[_author].push(_tokenId);

        emit ArticleCreated(
            _uid,
            _tokenId,
            _author,
            _price,
            _numMax,
            _authorBPS,
            _sharerBPS
        );
    }

    function mint(
        address receiver,
        uint id,
        uint amount
    ) public onlyRole(SALES_ROLE) {
        // Check that the Article exists. Note: this is redundant
        // with the next check, but it is useful for clearer error messaging.
        require(articles[id].numMax > 0, "Article does not exist");
        // Check that there are still tokens available to purchase.
        require(
            articles[id].numSold < articles[id].numMax,
            "This Article is already sold out."
        );
        require(
            articles[id].numSold + amount <= articles[id].numMax,
            "Exceed the maximum number of articles"
        );

        // Increment the number of tokens sold for this Article.
        articles[id].numSold += uint32(amount);

        _mint(receiver, id, amount, "");

        emit ArticleMinted(receiver, id, amount);
    }

    function mintBatch(
        address receiver,
        uint[] memory ids,
        uint[] memory amounts
    ) public onlyRole(SALES_ROLE) {
        for (uint i = 0; i < ids.length; i++) {
            require(articles[ids[i]].numMax > 0, "Article does not exist");
            // Check that there are still tokens available to purchase.
            require(
                articles[ids[i]].numSold < articles[ids[i]].numMax,
                "This Article is already sold out."
            );
            require(
                articles[ids[i]].numSold + amounts[i] <=
                    articles[ids[i]].numMax,
                "Exceed the maximum number of articles"
            );

            // Increment the number of tokens sold for this Article.
            articles[ids[i]].numSold += uint32(amounts[i]);
        }

        _mintBatch(receiver, ids, amounts, "");

        emit ArticleMintedBatch(receiver, ids, amounts);
    }

    function uri(uint _id) public view override returns (string memory) {
        require(exists(_id), "URI: nonexistent token");

        return string(abi.encodePacked(super.uri(_id), Strings.toString(_id)));
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
