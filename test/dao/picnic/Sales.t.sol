pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../../../src/picnic/ArticleFactory.sol";
import "../../../src/FakeUSDC.sol";

import "../../../src/picnic/Sales.sol";

contract SalesTest is Test {
    bytes32 private constant SALES_ROLE = keccak256("SALES_ROLE");

    address private platform = address(0xABCD);
    uint32 private platBPS = 1000;

    uint8 decimals = 6;
    uint256 usdcTotal = 1e15;

    ArticleFactory private af;
    FakeUSDC private usdc;
    Sales private sales;

    function baseSetUp() public {
        af = new ArticleFactory(
            "Article Factory",
            "AF",
            "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/",
            address(this)
        );

        usdc = new FakeUSDC("Fake USDC", "USDC", decimals, usdcTotal);
    }

    function setUp() public {
        baseSetUp();

        sales = new Sales(
            platform,
            address(af),
            address(usdc),
            platBPS
        );
    }

    function testGetBaseInfo() public {
        assertEq(usdc.balanceOf(address(this)), 1000000000000000);
    }

    function testCreateArticlePublicNotOpen() public {
        address from = address(0xABCD);

        bytes20 uid = bytes20(address(1));
        uint256 price = 1e7;
        uint32 numMax = 50;
        uint32 shareBPS = 1000;

        vm.expectRevert("Public create article is not open");
        vm.prank(from);
        sales.createArticlePublic(uid, price, numMax, shareBPS);
    }

    function testSetSalesRoleForCreateArticle() public {
        sales.setPulicCreate(true);

        af.grantRole(SALES_ROLE, address(this));
        bool status = af.hasRole(SALES_ROLE, address(this));
        assert(status);
    }

    function testCreateArticlePublic() public {
        testSetSalesRoleForCreateArticle();

        address from = address(0xABCD);

        bytes20 uid = bytes20(address(1));
        uint256 price = 1e7;
        uint32 numMax = 50;
        uint32 shareBPS = 1000;

        vm.prank(from);
        sales.createArticlePublic(uid, price, numMax, shareBPS);
    }
}