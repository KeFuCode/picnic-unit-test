pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../../../src/dao/pass_card/PicnicIdentity.sol";

contract PicnicIdentityTest is Test {
    bytes32 private constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    PicnicIdentity private pi;

    function setUp() public {
        pi = new PicnicIdentity(
            "Picnic Identity",
            "PI",
            "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/",
            address(this)
        );
    }

    // access control
    function testHasAdminRole() public view {
        bool status = pi.hasRole(bytes32(0), address(this));
        assert(status);
    }

    function testRevokeAdminRole() public {
        pi.revokeRole(bytes32(0), address(this));
        bool status = pi.hasRole(bytes32(0), address(this));
        assert(!status);
    }

    function testGrantExecutorRole() public {
        pi.grantRole(EXECUTOR_ROLE, address(1));
        bool status = pi.hasRole(EXECUTOR_ROLE, address(1));
        assert(status);
    }

    function testRevokeExecutorRoleByAdmin() public {
        pi.grantRole(EXECUTOR_ROLE, address(1));
        bool status = pi.hasRole(EXECUTOR_ROLE, address(1));
        assert(status);

        pi.revokeRole(EXECUTOR_ROLE, address(1));
        status = pi.hasRole(EXECUTOR_ROLE, address(1));
        assert(!status);
    }

    function testFailRevokeExecutorRoleByNoAdmin() public {
        pi.grantRole(EXECUTOR_ROLE, address(1));
        bool status = pi.hasRole(EXECUTOR_ROLE, address(1));
        assert(status);

        vm.startPrank(address(1));
        pi.revokeRole(EXECUTOR_ROLE, address(1));
        vm.stopPrank();
    }

    // send nft
    function testSendIdentity(uint256 id, uint256 amount) public {
        vm.assume(amount != 0);
        id = bound(id, 1, 100);

        testGrantExecutorRole();
        vm.startPrank(address(1));
        pi.sendIdentity(address(2), id, amount);
        vm.stopPrank();

        uint256 balance = pi.balanceOf(address(2), id);
        assertEq(balance, amount);
    }

    function testFailSendIdentityNoExecutor(uint256 amount) public {
        vm.assume(amount != 0);
        vm.startPrank(address(1));
        pi.sendIdentity(address(2), 1, amount);
        vm.stopPrank();
    }

    function testFailSendIdentityZeroId() public {
        testGrantExecutorRole();

        vm.startPrank(address(1));
        pi.sendIdentity(address(2), 0, 1);
        vm.stopPrank();
    }

    function testSendIdentityBatch() public {
        uint256[] memory ids = new uint256[](3);
        ids[0] = 1;
        ids[1] = 2;
        ids[2] = 3;

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 1;
        amounts[1] = 2;
        amounts[2] = 3;

        testGrantExecutorRole();
        vm.startPrank(address(1));
        pi.sendIdentityBatch(address(2), ids, amounts);
        vm.stopPrank();

        address[] memory accounts = new address[](3);
        accounts[0] = address(2);
        accounts[1] = address(2);
        accounts[2] = address(2);

        uint256[] memory balances = pi.balanceOfBatch(accounts, ids);
        assertEq(balances[0], 1);
        assertEq(balances[1], 2);
        assertEq(balances[2], 3);
    }

    // test transfer nft
    function testFailSafeTransferFromSelf() public {
        testSendIdentity(1, 1);

        vm.prank(address(2));
        pi.safeTransferFrom(address(2), address(3), 1, 1, "");
    }

    function testFailSafeTransferFromByOther() public {
        testSendIdentity(1, 1);

        vm.startPrank(address(2));
        pi.setApprovalForAll(address(this), true);
        vm.stopPrank();
        pi.safeTransferFrom(address(2), address(3), 1, 1, "");
    }

    function testFailSafeBatchTransferFromSelf() public {
        testSendIdentityBatch();

        uint256[] memory ids = new uint256[](3);
        ids[0] = 1;
        ids[1] = 2;
        ids[2] = 3;

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 1;
        amounts[1] = 2;
        amounts[2] = 3;

        vm.startPrank(address(2));
        pi.safeBatchTransferFrom(address(2), address(3), ids, amounts, "");
        vm.stopPrank();
    }

    function testFailSafeBatchTransferFromByOther() public {
        testSendIdentityBatch();

        vm.startPrank(address(2));
        pi.setApprovalForAll(address(this), true);
        vm.stopPrank();

        uint256[] memory ids = new uint256[](3);
        ids[0] = 1;
        ids[1] = 2;
        ids[2] = 3;

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 1;
        amounts[1] = 2;
        amounts[2] = 3;

        pi.safeBatchTransferFrom(address(2), address(3), ids, amounts, "");
    }
}
