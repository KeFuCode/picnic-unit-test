pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "murky/Merkle.sol";

import "../../src/FakeUSDC.sol";

import "../../src/picnic_upgradeable/ArticleFactoryUpgradeable.sol";
import "../../src/picnic_upgradeable/SalesUpgradeable.sol";
import "../../src/picnic_upgradeable/PoolUpgradeable.sol";
import "../../src/picnic_upgradeable/LPUpgradeable.sol";

import "../../src/UUPSProxy.sol";

contract SalesUpgradeableTest is Test {
    bytes32 public constant SALES_ROLE = keccak256("SALES_ROLE");
    bytes32 public constant POOL_ROLE = keccak256("POOL_ROLE");

    bytes32 constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    address public platform = address(0xABCD);
    uint32 public platBPS = 1000;

    uint8 decimals = 6;
    uint256 usdcTotal = 1e15;

    FakeUSDC public usdc;

    UUPSProxy afProxy;
    ArticleFactoryUpgradeable af;
    ArticleFactoryUpgradeable afWrappedProxyV1;

    UUPSProxy salesProxy;
    SalesUpgradeable public sales;
    SalesUpgradeable public salesWrappedProxyV1;

    UUPSProxy poolProxy;
    PoolUpgradeable public pool;
    PoolUpgradeable public poolWrappedProxyV1;

    UUPSProxy lpProxy;
    LPUpgradeable public lp;
    LPUpgradeable public lpWrappedProxyV1;

    Merkle m;
    bytes32[] public data;
    bytes32 public root;

    function baseUSDCSetUp() public {
        usdc = new FakeUSDC("Fake USDC", "USDC", decimals);
    }

    function baseArticleFactorySetUp() public {
        af = new ArticleFactoryUpgradeable();

        afProxy = new UUPSProxy(address(af), "");

        afWrappedProxyV1 = ArticleFactoryUpgradeable(address(afProxy));
        afWrappedProxyV1.initialize(
            "Article Factory",
            "AF",
            "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/",
            address(this)
        );
    }

    function baseSalesSetUp() public {
        sales = new SalesUpgradeable();

        salesProxy = new UUPSProxy(address(sales), "");

        salesWrappedProxyV1 = SalesUpgradeable(address(salesProxy));
        salesWrappedProxyV1.initialize(
            platform,
            address(afProxy),
            address(usdc),
            platBPS
        );
    }

    function basePoolSetUp() public {
        pool = new PoolUpgradeable();

        poolProxy = new UUPSProxy(address(pool), "");

        poolWrappedProxyV1 = PoolUpgradeable(address(poolProxy));
        poolWrappedProxyV1.initialize(address(0), address(usdc));
    }

    function baseLPSetUp() public {
        lp = new LPUpgradeable();

        lpProxy = new UUPSProxy(address(lp), "");

        lpWrappedProxyV1 = LPUpgradeable(address(lpProxy));
        lpWrappedProxyV1.initialize(
            address(salesProxy),
            address(poolProxy),
            address(this)
        );
    }

    function merkleTreeBaseSetUp() public {
        m = new Merkle();

        data = new bytes32[](4);
        data[0] = keccak256(abi.encodePacked(address(1)));
        data[1] = keccak256(abi.encodePacked(address(2)));
        data[2] = keccak256(abi.encodePacked(address(3)));
        data[3] = keccak256(abi.encodePacked(address(4)));

        root = m.getRoot(data);
    }

    function setUp() public {
        merkleTreeBaseSetUp();
        baseUSDCSetUp();

        baseArticleFactorySetUp();
        baseSalesSetUp();
        basePoolSetUp();

        salesWrappedProxyV1.setPool(address(poolProxy));

        baseLPSetUp();

        salesWrappedProxyV1.setLP(address(lpProxy));
        poolWrappedProxyV1.setLP(address(lpProxy));
    }

    function testRoleInLP() public {
        assertTrue(lpWrappedProxyV1.hasRole(SALES_ROLE, address(salesProxy)));
        assertTrue(lpWrappedProxyV1.hasRole(POOL_ROLE, address(poolProxy)));
    }

    function testCreateArticlePublicNotOpen() public {
        address from = address(0xABCD);

        bytes20 uid = bytes20(address(1));
        uint256 price = 1e7;
        uint32 numMax = 50;
        uint32 shareBPS = 1000;

        vm.expectRevert("Public create article is not open");
        vm.prank(from);
        salesWrappedProxyV1.createArticlePublic(uid, price, numMax, shareBPS);
    }

    function testSetPulicCreate() public {
        assertEq(salesWrappedProxyV1.isPublicCreate(), false);
        salesWrappedProxyV1.setPulicCreate(true);
        assertEq(salesWrappedProxyV1.isPublicCreate(), true);
    }

    function testSetSalesRole() public {
        afWrappedProxyV1.grantRole(SALES_ROLE, address(salesProxy));
        bool status = afWrappedProxyV1.hasRole(SALES_ROLE, address(salesProxy));
        assert(status);
    }

    function testCreateArticlePublic() public {
        testSetPulicCreate();
        testSetSalesRole();

        address from = address(0xABCD);

        bytes20 uid = bytes20(address(1));
        uint256 price = 1e7;
        uint32 numMax = 50;
        uint32 shareBPS = 1000;

        vm.prank(from);
        salesWrappedProxyV1.createArticlePublic(uid, price, numMax, shareBPS);
    }

    function testFailCreateArticlePublicNoSalesRole() public {
        testSetPulicCreate();

        address from = address(0xABCD);

        bytes20 uid = bytes20(address(1));
        uint256 price = 1e7;
        uint32 numMax = 50;
        uint32 shareBPS = 1000;

        vm.prank(from);
        salesWrappedProxyV1.createArticlePublic(uid, price, numMax, shareBPS);
    }

    function testSetWhiteListCreate() public {
        assertEq(salesWrappedProxyV1.isWhiteListCreate(), false);
        salesWrappedProxyV1.setWhiteListCreate(true);
        assertEq(salesWrappedProxyV1.isWhiteListCreate(), true);
    }

    function testSetwhiteListMerkleRoot() public {
        salesWrappedProxyV1.setwhiteListMerkleRoot(root);
        assertEq(salesWrappedProxyV1.whiteListMerkleRoot(), root);
    }

    function testCreateArticleWhiteList() public {
        testSetSalesRole();
        testSetWhiteListCreate();
        testSetwhiteListMerkleRoot();

        address from = address(2);

        bytes20 uid = bytes20(address(1));
        uint256 price = 1e7;
        uint32 numMax = 50;
        uint32 shareBPS = 1000;
        bytes32[] memory proof = m.getProof(data, 1);

        bool verified = m.verifyProof(root, proof, data[1]);
        assertTrue(verified);

        vm.prank(from);
        salesWrappedProxyV1.createArticleWhiteList(
            uid,
            price,
            numMax,
            shareBPS,
            proof
        );
    }

    function testPermit() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    usdc.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            owner,
                            address(salesProxy),
                            1e10,
                            0,
                            block.timestamp
                        )
                    )
                )
            )
        );

        usdc.permit(owner, address(salesProxy), 1e10, block.timestamp, v, r, s);

        assertEq(usdc.allowance(owner, address(salesProxy)), 1e10);
        assertEq(usdc.nonces(owner), 1);
    }

    function testUsdcMint() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        assertEq(usdc.balanceOf(owner), 0);
        usdc.mint(owner, usdcTotal);
        assertEq(usdc.balanceOf(owner), usdcTotal);
    }

    function testBuyArticleSharer() public {
        testCreateArticlePublic();

        testUsdcMint();

        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);
        testPermit();

        vm.prank(owner);
        salesWrappedProxyV1.buyArticle(1, 10, address(0xCDDF));
        assertEq(lpWrappedProxyV1.balanceOf(platform), 90000000);
        assertEq(lpWrappedProxyV1.balanceOf(address(0xCDDF)), 10000000);
    }

    function testBuyArticleNoSharer() public {
        testCreateArticlePublic();

        testUsdcMint();

        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);
        testPermit();

        vm.prank(owner);
        salesWrappedProxyV1.buyArticle(1, 10, address(0));
        assertEq(lpWrappedProxyV1.balanceOf(address(0xABCD)), 100000000);
    }

    function testWithdrawFunds() public {
        testBuyArticleNoSharer();

        assertEq(lpWrappedProxyV1.balanceOf(address(0xABCD)), 100000000);
        vm.prank(address(0xABCD));
        poolWrappedProxyV1.withdrawFunds(1e7);
        assertEq(lpWrappedProxyV1.balanceOf(address(0xABCD)), 90000000);
    }
}
