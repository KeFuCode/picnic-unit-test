pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../../../src/dao/pass_card/PicnicIdentity.sol";

contract PicnicIdentityTest is Test {
    PicnicIdentity private pi;

    function setUp() public {
        pi = new PicnicIdentityManage(
            "Picnic Identity",
            "PI",
            "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/",
            address(this)
        );
    }

    
}
