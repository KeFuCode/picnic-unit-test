pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../../../src/picnic/ArticleFactory.sol";

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
        uint tokenId = 1;
        address author = address(1);
        uint price = 1e7;
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
        uint tokenId = 1;
        address author = address(1);
        uint price = 1e7;
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

    function testFailMintBySalesRoleNoTokenId() public {
        testCreateArticleBySalesRole();

        vm.prank(address(1));
        af.mint(address(2), 0, 10);
    }

    function testFailMintBySalesRoleBeyondAmount() public {
        testCreateArticleBySalesRole();

        vm.startPrank(address(1));

        af.mint(address(2), 1, 10);
        assertEq(af.balanceOf(address(2), 1), 10);
        
        af.mint(address(2), 1, 15);
        assertEq(af.balanceOf(address(2), 1), 50);

        vm.stopPrank(); 
    }
}
