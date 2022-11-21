pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../../../src/picnic/ArticleFactory";

contract ArticleFactoryTest is Test {
    bytes32 private constant SALES_ROLE = keccak256("SALES_ROLE");

    ArticleFactory private af;

    function setUp() public {
        af = new ArticleFactory();
    }
}