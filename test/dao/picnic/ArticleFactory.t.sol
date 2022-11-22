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

    // test create
    function testCreateArticleBySalesRole() public {
        testGrantSalesRole();

        uint price = 1e7;

        vm.startPrank(address(1));
        af.createArticle(
            bytes20(1),
            1,
            address(1),
            price,
            50,
            8000,
            1000
        );
        vm.stopPrank();
    }

    function testFailCreateArticleNoSalesRole() public {}

    // test mint
}
