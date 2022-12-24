pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/UUPSProxy.sol";

import "../src/FakeUSDC.sol";

import "../src/picnic_upgradeable/ArticleFactoryUpgradeable.sol";
import "../src/picnic_upgradeable/SalesUpgradeable.sol";
import "../src/picnic_upgradeable/PoolUpgradeable.sol";
import "../src/picnic_upgradeable/LPUpgradeable.sol";

contract DeployPicnicUpgradeable is Script {
    bytes32 public constant SALES_ROLE = keccak256("SALES_ROLE");

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

    uint8 decimals = 6;

    address public platform = 0xB20E2089E454E1a2F236DA1774412196B50421D7;
    uint32 public platBPS = 1000;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // baseUSDCSetUp();
        // usdc = FakeUSDC(0x8c92ef4263d4c8d8E6C4AE7FeA3E59C215122F70);
        usdc = FakeUSDC(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174); // polygon usdc address

        baseArticleFactorySetUp();
        baseSalesSetUp();

        afWrappedProxyV1.grantRole(SALES_ROLE, address(salesProxy));

        basePoolSetUp();

        salesWrappedProxyV1.setPool(address(poolProxy));

        baseLPSetUp();

        salesWrappedProxyV1.setLP(address(lpProxy));
        poolWrappedProxyV1.setLP(address(lpProxy));

        salesWrappedProxyV1.setPulicCreate(true);

        vm.stopBroadcast();
    }


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
            0x75397574f510239621050b35147656a3587A9678
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
            0x75397574f510239621050b35147656a3587A9678
        );
    }
}