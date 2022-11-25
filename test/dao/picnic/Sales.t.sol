pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "murky/Merkle.sol";

import "../../../src/picnic/ArticleFactory.sol";
import "../../../src/FakeUSDC.sol";
import "../../../src/picnic/Pool.sol";
import "../../../src/picnic/LP.sol";

import "../../../src/picnic/Sales.sol";

contract SalesTest is Test {
    bytes32 private constant SALES_ROLE = keccak256("SALES_ROLE");

    bytes32 constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    address private platform = address(0xABCD);
    uint32 private platBPS = 1000;

    uint8 decimals = 6;
    uint256 usdcTotal = 1e15;

    ArticleFactory private af;
    FakeUSDC private usdc;
    Sales private sales;
    Pool private pool;
    LP private lp;

    Merkle m;
    bytes32[] private data;
    bytes32 private root;

    struct Article {
        address author;
        uint256 price;
        uint32 authorBPS;
        uint32 sharerBPS;
    }

    function baseSetUp() public {
        af = new ArticleFactory(
            "Article Factory",
            "AF",
            "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/",
            address(this)
        );

        usdc = new FakeUSDC("Fake USDC", "USDC", decimals);
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
        baseSetUp();
        merkleTreeBaseSetUp();

        sales = new Sales(platform, address(af), address(usdc), platBPS);

        pool = new Pool(address(0), address(usdc));
        sales.setPool(address(pool));

        lp = new LP(address(sales), address(pool), address(this));

        pool.setLP(address(lp));
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

    function testSetPulicCreate() public {
        assertEq(sales.isPublicCreate(), false);
        sales.setPulicCreate(true);
        assertEq(sales.isPublicCreate(), true);
    }

    function testSetSalesRole() public {
        af.grantRole(SALES_ROLE, address(sales));
        bool status = af.hasRole(SALES_ROLE, address(sales));
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
        sales.createArticlePublic(uid, price, numMax, shareBPS);
    }

    function testCreateArticlePublicNoSalesRole() public {
        testSetPulicCreate();

        address from = address(0xABCD);

        bytes20 uid = bytes20(address(1));
        uint256 price = 1e7;
        uint32 numMax = 50;
        uint32 shareBPS = 1000;

        vm.expectRevert(
            "AccessControl: account 0xf5a2fe45f4f1308502b1c136b9ef8af136141382 is missing role 0xdeccffc5821b949817830292498e44ccb6097e4b74ff2f2db960723873324def"
        );
        vm.prank(from);
        sales.createArticlePublic(uid, price, numMax, shareBPS);
    }

    function testSetWhiteListCreate() public {
        assertEq(sales.isWhiteListCreate(), false);
        sales.setWhiteListCreate(true);
        assertEq(sales.isWhiteListCreate(), true);
    }

    function testSetwhiteListMerkleRoot() public {
        sales.setwhiteListMerkleRoot(root);
        assertEq(sales.whiteListMerkleRoot(), root);
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
        sales.createArticleWhiteList(uid, price, numMax, shareBPS, proof);
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
                            address(sales),
                            1e10,
                            0,
                            block.timestamp
                        )
                    )
                )
            )
        );

        usdc.permit(owner, address(sales), 1e10, block.timestamp, v, r, s);

        assertEq(usdc.allowance(owner, address(sales)), 1e10);
        assertEq(usdc.nonces(owner), 1);
    }

    function testUsdcMint() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        assertEq(usdc.balanceOf(owner), 0);
        usdc.mint(owner, usdcTotal);
        assertEq(usdc.balanceOf(owner), usdcTotal);
    }

    function testBuyArticle() public {
        testCreateArticlePublic();
        
        testUsdcMint();

        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);
        testPermit();

        vm.prank(owner);
        sales.buyArticle(1, 10, address(0));
    }
}
