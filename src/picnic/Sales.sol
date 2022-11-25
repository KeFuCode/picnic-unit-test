// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.7;

import "openzeppelin-contracts/utils/Counters.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/utils/cryptography/MerkleProof.sol";

import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IArticleFactory.sol";
import "./interfaces/ILP.sol";

contract Sales is Ownable {
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;

    // ============ Structs ============
    struct Article {
        address author;
        uint256 price;
        uint32 authorBPS;
        uint32 sharerBPS;
    }

    // ============ Storage ============
    bytes32 public whiteListMerkleRoot;

    bool public isPublicCreate;
    bool public isWhiteListCreate;

    uint32 public platBPS;
    address public ArticleFactory;
    address public LP;
    address public Platform;
    address public TokenAddress;
    address payable public Pool;

    mapping(uint256 => Article) public articles;

    Counters.Counter private atTokenId;

    // ============ Events ============

    event ArticlePurchased(
        uint256 indexed tokenId,
        address indexed buyer,
        address indexed sharer,
        uint256 amount
    );

    // ============ Modifiers ==========

    modifier isValidMerkleProof(bytes32[] calldata merkleProof, bytes32 root) {
        require(
            MerkleProof.verify(
                merkleProof,
                root,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "Address does not exist in list"
        );
        _;
    }

    modifier publicCreate() {
        require(isPublicCreate, "Public create article is not open");
        _;
    }

    modifier whiteListCreate() {
        require(isWhiteListCreate, "WhiteList create article is not open");
        _;
    }

    // ============ Methods ============

    constructor(
        address _platform,
        address _articleFactory,
        address _tokenAddress,
        uint32 _platBPs
    ) {
        Platform = _platform;
        ArticleFactory = _articleFactory;
        TokenAddress = _tokenAddress;
        platBPS = _platBPs;
        atTokenId.increment();
    }

    function createArticlePublic(
        bytes20 _uid,
        uint256 _price,
        uint32 _quantity,
        uint32 _sharerBPS
    ) external publicCreate {
        uint32 _authorBPS = 10000 - _sharerBPS - platBPS;

        articles[atTokenId.current()] = Article({
            author: msg.sender,
            price: _price,
            authorBPS: _authorBPS,
            sharerBPS: _sharerBPS
        });

        IArticleFactory(ArticleFactory).createArticle(
            _uid,
            atTokenId.current(),
            msg.sender,
            _price,
            _quantity,
            _authorBPS,
            _sharerBPS
        );

        atTokenId.increment();
    }

    function createArticleWhiteList(
        bytes20 _uid,
        uint256 _price,
        uint32 _quantity,
        uint32 _sharerBPS,
        bytes32[] calldata merkleProof
    )
        external
        whiteListCreate
        isValidMerkleProof(merkleProof, whiteListMerkleRoot)
    {
        uint32 _authorBPS = 10000 - _sharerBPS - platBPS;

        articles[atTokenId.current()] = Article({
            author: msg.sender,
            price: _price,
            authorBPS: _authorBPS,
            sharerBPS: _sharerBPS
        });

        IArticleFactory(ArticleFactory).createArticle(
            _uid,
            atTokenId.current(),
            msg.sender,
            _price,
            _quantity,
            _authorBPS,
            _sharerBPS
        );

        atTokenId.increment();
    }

    function buyArticle(
        uint256 _tokenId,
        uint256 _amount,
        address _sharer
    ) external {
        require(
            ArticleFactory != address(0),
            "The ArticleFactory's address is not exist"
        );
        require(Pool != address(0), "The Pool's address is not exist");

        IERC20(TokenAddress).safeTransferFrom(
            msg.sender,
            address(Pool),
            articles[_tokenId].price * _amount
        );

        IArticleFactory(ArticleFactory).mint(msg.sender, _tokenId, _amount);

        (
            uint256 platAmount,
            uint256 authorAmount,
            uint256 sharerAmount
        ) = _split(_tokenId, _sharer);

        _mintLP(
            _tokenId,
            _sharer,
            platAmount * _amount,
            authorAmount * _amount,
            sharerAmount * _amount
        );

        emit ArticlePurchased(_tokenId, msg.sender, _sharer, _amount);
    }

    function setTokenAddress(address _tokenAddress) external onlyOwner {
        TokenAddress = _tokenAddress;
    }

    function setArticleFactory(address _articleFactory) external onlyOwner {
        ArticleFactory = _articleFactory;
    }

    function setLP(address _LP) external onlyOwner {
        LP = _LP;
    }

    function setPool(address _Pool) external onlyOwner {
        Pool = payable(_Pool);
    }

    function setPlat(address _platform) external onlyOwner {
        Platform = _platform;
    }

    function setPlatBPS(uint32 _platBPS) external onlyOwner {
        platBPS = _platBPS;
    }

    function setwhiteListMerkleRoot(bytes32 merkleRoot) external onlyOwner {
        whiteListMerkleRoot = merkleRoot;
    }

    function setPulicCreate(bool _isPublicCreate) external onlyOwner {
        isPublicCreate = _isPublicCreate;
    }

    function setWhiteListCreate(bool _isWhiteListCreate) external onlyOwner {
        isWhiteListCreate = _isWhiteListCreate;
    }

    // ============ Private Methods ============

    function _mintLP(
        uint256 _tokenId,
        address _sharer,
        uint256 _platAmount,
        uint256 _authorAmount,
        uint256 _sharerAmount
    ) private {
        ILP(LP).sendLP(Platform, _platAmount);
        ILP(LP).sendLP(articles[_tokenId].author, _authorAmount);
        if (_sharerAmount != 0) {
            ILP(LP).sendLP(_sharer, _sharerAmount);
        }
    }

    // ============ View Methods ============

    function _split(uint256 _articleId, address _sharer)
        internal
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 platAmount = (articles[_articleId].price * platBPS) / 10000;

        if (_sharer == address(0x00)) {
            uint256 authorAmount = articles[_articleId].price - platAmount;
            return (platAmount, authorAmount, 0);
        } else {
            uint256 sharerAmount = (articles[_articleId].price *
                articles[_articleId].sharerBPS) / 10000;
            uint256 authorAmount = articles[_articleId].price -
                platAmount -
                sharerAmount;
            return (platAmount, authorAmount, sharerAmount);
        }
    }
}
