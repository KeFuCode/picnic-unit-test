pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../../src/picnic/ArticleFactory.sol";

contract ArticleFactoryTest is Test {
    bytes32 private constant SALES_ROLE = keccak256("SALES_ROLE");

    ArticleFactory private af;

    function setUp() public {
        af = new ArticleFactory(
            "Article Factory",
            "AF",
            "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/",
            address(this)
        );
    }

    // access control
    function testHasAdminRole() public view {
        bool status = af.hasRole(bytes32(0), address(this));
        assert(status);
    }

    function testRevokeAdminRole() public {
        af.revokeRole(bytes32(0), address(this));
        bool status = af.hasRole(bytes32(0), address(this));
        assert(!status);
    }

    function testGrantSalesRole() public {
        af.grantRole(SALES_ROLE, address(1));
        bool status = af.hasRole(SALES_ROLE, address(1));
        assert(status);
    }

    function testRevokeSalesRoleByAdmin() public {
        af.grantRole(SALES_ROLE, address(1));
        bool status = af.hasRole(SALES_ROLE, address(1));
        assert(status);

        af.revokeRole(SALES_ROLE, address(1));
        status = af.hasRole(SALES_ROLE, address(1));
        assert(!status);
    }

    function testFailRevokeSalesRoleByNoAdmin() public {
        af.grantRole(SALES_ROLE, address(1));
        bool status = af.hasRole(SALES_ROLE, address(1));
        assert(status);

        vm.startPrank(address(1));
        af.revokeRole(SALES_ROLE, address(1));
        vm.stopPrank();
    }

    // test create article
    function testCreateArticleBySalesRole() public {
        testGrantSalesRole();

        bytes20 uid = bytes20(address(1));
        uint256 tokenId = 1;
        address author = address(1);
        uint256 price = 1e7;
        uint32 numMax = 50;
        uint32 authorBPS = 8000;
        uint32 shareBPS = 1000;

        vm.prank(address(1));
        af.createArticle(
            uid,
            tokenId,
            author,
            price,
            numMax,
            authorBPS,
            shareBPS
        );
    }

    function testFailCreateArticleNoSalesRole() public {
        bytes20 uid = bytes20(address(1));
        uint256 tokenId = 1;
        address author = address(1);
        uint256 price = 1e7;
        uint32 numMax = 50;
        uint32 authorBPS = 8000;
        uint32 shareBPS = 1000;

        vm.prank(address(1));
        af.createArticle(
            uid,
            tokenId,
            author,
            price,
            numMax,
            authorBPS,
            shareBPS
        );
    }

    // test mint
    function testMintBySalesRole() public {
        testCreateArticleBySalesRole();

        vm.startPrank(address(1));

        af.mint(address(2), 1, 10);
        assertEq(af.balanceOf(address(2), 1), 10);

        af.mint(address(2), 1, 15);
        assertEq(af.balanceOf(address(2), 1), 25);

        vm.stopPrank();
    }

    function testFailMintNoSalesRole() public {
        testCreateArticleBySalesRole();

        af.mint(address(2), 1, 10);
        assertEq(af.balanceOf(address(2), 1), 10);
    }

    function testFailMintBySalesRoleNoTokenId() public {
        testCreateArticleBySalesRole();

        vm.prank(address(1));
        af.mint(address(2), 0, 10);
    }

    function testFailMintBySalesRoleOverAmount() public {
        testCreateArticleBySalesRole();

        vm.startPrank(address(1));

        af.mint(address(2), 1, 10);
        assertEq(af.balanceOf(address(2), 1), 10);

        af.mint(address(2), 1, 15);
        assertEq(af.balanceOf(address(2), 1), 50);

        vm.stopPrank();
    }

    function testFailMintBySalesRoleZeroAmount() public {
        testCreateArticleBySalesRole();

        vm.prank(address(1));
        af.mint(address(2), 1, 0);
    }

    // test mint batch
    function testMintBatchBySalesRole() public {
        testGrantSalesRole();

        uint256[] memory ids = new uint256[](3);
        ids[0] = 1;
        ids[1] = 2;
        ids[2] = 3;
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 11;
        amounts[1] = 22;
        amounts[2] = 33;
        bytes20 uid = bytes20(address(1));
        address author = address(1);
        uint256 price = 1e7;
        uint32 numMax = 50;
        uint32 authorBPS = 8000;
        uint32 shareBPS = 1000;

        vm.startPrank(address(1));
        af.createArticle(
            uid,
            ids[0],
            author,
            price,
            numMax,
            authorBPS,
            shareBPS
        );
        af.createArticle(
            uid,
            ids[1],
            author,
            price,
            numMax,
            authorBPS,
            shareBPS
        );
        af.createArticle(
            uid,
            ids[2],
            author,
            price,
            numMax,
            authorBPS,
            shareBPS
        );

        address[] memory accounts = new address[](3);
        accounts[0] = address(2);
        accounts[1] = address(2);
        accounts[2] = address(2);
        uint256[] memory balances = new uint256[](3);
        balances[0] = 11;
        balances[1] = 22;
        balances[2] = 33;

        af.mintBatch(address(2), ids, amounts);
        assertEq(af.balanceOfBatch(accounts, ids), balances);
        assertEq(
            af.uri(ids[0]),
            "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/1"
        );
        assertEq(
            af.uri(ids[1]),
            "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/2"
        );
        assertEq(
            af.uri(ids[2]),
            "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/3"
        );

        vm.stopPrank();
    }

    function testFailMintBatchNoSalesRole() public {
        testGrantSalesRole();

        uint256[] memory ids = new uint256[](3);
        ids[0] = 1;
        ids[1] = 2;
        ids[2] = 3;
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 11;
        amounts[1] = 22;
        amounts[2] = 33;
        bytes20 uid = bytes20(address(1));
        address author = address(1);
        uint256 price = 1e7;
        uint32 numMax = 50;
        uint32 authorBPS = 8000;
        uint32 shareBPS = 1000;

        vm.startPrank(address(1));
        af.createArticle(
            uid,
            ids[0],
            author,
            price,
            numMax,
            authorBPS,
            shareBPS
        );
        af.createArticle(
            uid,
            ids[1],
            author,
            price,
            numMax,
            authorBPS,
            shareBPS
        );
        af.createArticle(
            uid,
            ids[2],
            author,
            price,
            numMax,
            authorBPS,
            shareBPS
        );
        vm.stopPrank();

        address[] memory accounts = new address[](3);
        accounts[0] = address(2);
        accounts[1] = address(2);
        accounts[2] = address(2);
        uint256[] memory balances = new uint256[](3);
        balances[0] = 11;
        balances[1] = 22;
        balances[2] = 33;

        af.mintBatch(address(2), ids, amounts);
    }

    function testFailMintBatchBySalesRoleNoTokenId() public {
        testGrantSalesRole();

        uint256[] memory ids = new uint256[](3);
        ids[0] = 1;
        ids[1] = 2;
        ids[2] = 3;
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 11;
        amounts[1] = 22;
        amounts[2] = 33;
        bytes20 uid = bytes20(address(1));
        address author = address(1);
        uint256 price = 1e7;
        uint256 tokenId = 4;
        uint32 numMax = 50;
        uint32 authorBPS = 8000;
        uint32 shareBPS = 1000;

        vm.startPrank(address(1));
        af.createArticle(
            uid,
            ids[0],
            author,
            price,
            numMax,
            authorBPS,
            shareBPS
        );
        af.createArticle(
            uid,
            ids[1],
            author,
            price,
            numMax,
            authorBPS,
            shareBPS
        );
        af.createArticle(
            uid,
            tokenId,
            author,
            price,
            numMax,
            authorBPS,
            shareBPS
        );

        address[] memory accounts = new address[](3);
        accounts[0] = address(2);
        accounts[1] = address(2);
        accounts[2] = address(2);
        uint256[] memory balances = new uint256[](3);
        balances[0] = 11;
        balances[1] = 22;
        balances[2] = 33;

        af.mintBatch(address(2), ids, amounts);

        vm.stopPrank();
    }

    function testFailMintBatchBySalesRoleOverAmount() public {
        testGrantSalesRole();

        uint256[] memory ids = new uint256[](3);
        ids[0] = 1;
        ids[1] = 2;
        ids[2] = 3;
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 11;
        amounts[1] = 22;
        amounts[2] = 33;
        bytes20 uid = bytes20(address(1));
        address author = address(1);
        uint256 price = 1e7;
        uint32 numMax = 50;
        uint32 authorBPS = 8000;
        uint32 shareBPS = 1000;

        vm.startPrank(address(1));
        af.createArticle(
            uid,
            ids[0],
            author,
            price,
            numMax,
            authorBPS,
            shareBPS
        );
        af.createArticle(
            uid,
            ids[1],
            author,
            price,
            numMax,
            authorBPS,
            shareBPS
        );
        af.createArticle(
            uid,
            ids[2],
            author,
            price,
            numMax,
            authorBPS,
            shareBPS
        );

        address[] memory accounts = new address[](3);
        accounts[0] = address(2);
        accounts[1] = address(2);
        accounts[2] = address(2);
        uint256[] memory balances = new uint256[](3);
        balances[0] = 11;
        balances[1] = 22;
        balances[2] = 33;

        af.mintBatch(address(2), ids, amounts);
        assertEq(af.balanceOfBatch(accounts, ids), balances);

        af.mintBatch(address(2), ids, amounts);

        vm.stopPrank();
    }

    function testFailMintBatchBySalesRoleZeroAmount() public {
        testGrantSalesRole();

        uint256[] memory ids = new uint256[](3);
        ids[0] = 1;
        ids[1] = 2;
        ids[2] = 3;
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 11;
        amounts[1] = 22;
        amounts[2] = 33;
        bytes20 uid = bytes20(address(1));
        address author = address(1);
        uint256 price = 1e7;
        uint32 numMax = 50;
        uint32 authorBPS = 8000;
        uint32 shareBPS = 1000;

        vm.startPrank(address(1));
        af.createArticle(
            uid,
            ids[0],
            author,
            price,
            numMax,
            authorBPS,
            shareBPS
        );
        af.createArticle(
            uid,
            ids[1],
            author,
            price,
            numMax,
            authorBPS,
            shareBPS
        );
        af.createArticle(
            uid,
            ids[2],
            author,
            price,
            numMax,
            authorBPS,
            shareBPS
        );

        address[] memory accounts = new address[](3);
        accounts[0] = address(2);
        accounts[1] = address(2);
        accounts[2] = address(2);
        uint256[] memory balances = new uint256[](3);
        balances[0] = 11;
        balances[1] = 22;
        balances[2] = 33;

        amounts[2] = 0;
        af.mintBatch(address(2), ids, amounts);

        vm.stopPrank();
    }
}
