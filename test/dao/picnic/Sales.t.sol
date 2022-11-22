pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../../../src/picnic/ArticleFactory.sol";

import "../../../src/picnic/Sales.sol";

contract SalesTest is Test {
    address private platForm = address(0xABCD);
    uint32 private platBPS = 1000;

    ArticleFactory private af;
    FakeUSDT private usdt;
    Sales private sales;

    function baseSetUp() public {
        af = new ArticleFactory(
            "Article Factory",
            "AF",
            "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/",
            address(this)
        );

        usdt = new FakeUSDT();
    }

    function setUp() public {
        sales = new Sales(
            platForm,
            address(af),
            address(usdt),
            platBPS
        );
    }
}