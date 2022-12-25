pragma solidity ^0.8.10;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import "../../../src/dao/token/Point.sol";

contract PointTest is Test {
    Point private pp;

    function setUp() public {
        pp = new Point("Picnic Point", "PP");
        console.log(address(this));
    }

    function testOwner() public {
        assertEq(address(this), pp.owner());
    }

    function testTransferOwnership() public {
        pp.transferOwnership(address(1));
        assertEq(address(1), pp.owner());
    }

    function testFailTransferOwnership() public {
        pp.transferOwnership(address(0));
        assertEq(address(1), pp.owner());
    }

    function testRenounceOwnership() public {
        pp.renounceOwnership();
        assertEq(address(0), pp.owner());
    }

    function testFailRenounceOwnership() public {
        vm.startPrank(address(1));
        pp.renounceOwnership();
        vm.stopPrank();
    }

    function testSendTokenAsOwner() public {
        pp.sendToken(address(2), 1);
        assertEqDecimal(pp.balanceOf(address(2)), 1, pp.decimals());
    }

    function testSendTokenAsNotOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.startPrank(address(1));
        pp.sendToken(address(2), 1);
        vm.stopPrank();
    }

    function testFailTransfer() public {
        pp.sendToken(address(1), 1);
        assertEqDecimal(pp.balanceOf(address(1)), 1, pp.decimals());

        vm.startPrank(address(1));
        pp.transfer(address(2), 1);
        assertEqDecimal(pp.balanceOf(address(1)), 0, pp.decimals());
        assertEqDecimal(pp.balanceOf(address(2)), 1, pp.decimals());
        vm.stopPrank();
    }

    function testFailTransferFrom() public {
        pp.sendToken(address(1), 1);
        assertEqDecimal(pp.balanceOf(address(1)), 1, pp.decimals());

        vm.startPrank(address(1));
        pp.approve(address(2), 1);
        vm.stopPrank();
        assertEqDecimal(pp.allowance(address(1), address(2)), 1, pp.decimals());

        vm.startPrank(address(2));
        pp.transferFrom(address(1), address(3), 1);
        vm.stopPrank();
    }
}
