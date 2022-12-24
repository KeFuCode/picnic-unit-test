pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../../src/picnic_upgradeable/ArticleFactoryUpgradeable.sol";
import "../../src/ArticleFactoryUpgradeableV2.sol";

import "../../src/UUPSProxy.sol";

contract ArticleFactoryUpgradeableTest is Test {
    bytes32 private constant SALES_ROLE = keccak256("SALES_ROLE");

    UUPSProxy proxy;

    ArticleFactoryUpgradeable af;
    ArticleFactoryUpgradeableV2 afv2;

    ArticleFactoryUpgradeable wrappedProxyV1;
    ArticleFactoryUpgradeableV2 wrappedProxyV2;

    function setUp() public {
        af = new ArticleFactoryUpgradeable();

        proxy = new UUPSProxy(address(af), "");

        wrappedProxyV1 = ArticleFactoryUpgradeable(address(proxy));

        wrappedProxyV1.initialize(
            "Article Factory",
            "AF",
            "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/",
            address(this)
        );
    }

    function testUpgradeToV2() public {
        afv2 = new ArticleFactoryUpgradeableV2();

        wrappedProxyV1.upgradeTo(address(afv2));

        wrappedProxyV2 = ArticleFactoryUpgradeableV2(address(proxy));
        assertEq(wrappedProxyV2.x(), 0);
        assertEq(wrappedProxyV2.y(), 0);
    }

    function testFailUpgradeToV2() public {
        afv2 = new ArticleFactoryUpgradeableV2();

        vm.prank(address(0xBCEF));
        wrappedProxyV1.upgradeTo(address(afv2));

        wrappedProxyV2 = ArticleFactoryUpgradeableV2(address(proxy));
        assertEq(wrappedProxyV2.x(), 0);
        assertEq(wrappedProxyV2.y(), 0);
    }

    function testCallV2() public {
        testUpgradeToV2();

        wrappedProxyV2.setX(100);
        assertEq(wrappedProxyV2.x(), 100);

        wrappedProxyV2.setY(200);
        assertEq(wrappedProxyV2.y(), 200);
    }

    // access control
    function testHasAdminRole() public view {
        bool status = wrappedProxyV1.hasRole(bytes32(0), address(this));
        assert(status);
    }

    function testRevokeAdminRole() public {
        wrappedProxyV1.revokeRole(bytes32(0), address(this));
        bool status = wrappedProxyV1.hasRole(bytes32(0), address(this));
        assert(!status);
    }

    function testGrantSalesRole() public {
        wrappedProxyV1.grantRole(SALES_ROLE, address(1));
        bool status = wrappedProxyV1.hasRole(SALES_ROLE, address(1));
        assert(status);
    }

    function testRevokeSalesRoleByAdmin() public {
        wrappedProxyV1.grantRole(SALES_ROLE, address(1));
        bool status = wrappedProxyV1.hasRole(SALES_ROLE, address(1));
        assert(status);

        wrappedProxyV1.revokeRole(SALES_ROLE, address(1));
        status = wrappedProxyV1.hasRole(SALES_ROLE, address(1));
        assert(!status);
    }

    function testFailRevokeSalesRoleByNoAdmin() public {
        wrappedProxyV1.grantRole(SALES_ROLE, address(1));
        bool status = wrappedProxyV1.hasRole(SALES_ROLE, address(1));
        assert(status);

        vm.startPrank(address(1));
        wrappedProxyV1.revokeRole(SALES_ROLE, address(1));
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
        wrappedProxyV1.createArticle(
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
        wrappedProxyV1.createArticle(
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

        wrappedProxyV1.mint(address(2), 1, 10);
        assertEq(wrappedProxyV1.balanceOf(address(2), 1), 10);

        wrappedProxyV1.mint(address(2), 1, 15);
        assertEq(wrappedProxyV1.balanceOf(address(2), 1), 25);

        vm.stopPrank();
    }

    function testFailMintNoSalesRole() public {
        testCreateArticleBySalesRole();

        wrappedProxyV1.mint(address(2), 1, 10);
        assertEq(wrappedProxyV1.balanceOf(address(2), 1), 10);
    }

    function testFailMintBySalesRoleNoTokenId() public {
        testCreateArticleBySalesRole();

        vm.prank(address(1));
        wrappedProxyV1.mint(address(2), 0, 10);
    }

    function testFailMintBySalesRoleOverAmount() public {
        testCreateArticleBySalesRole();

        vm.startPrank(address(1));

        wrappedProxyV1.mint(address(2), 1, 10);
        assertEq(wrappedProxyV1.balanceOf(address(2), 1), 10);

        wrappedProxyV1.mint(address(2), 1, 15);
        assertEq(wrappedProxyV1.balanceOf(address(2), 1), 50);

        vm.stopPrank();
    }

    function testFailMintBySalesRoleZeroAmount() public {
        testCreateArticleBySalesRole();

        vm.prank(address(1));
        wrappedProxyV1.mint(address(2), 1, 0);
    }
}
