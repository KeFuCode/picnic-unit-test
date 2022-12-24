pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/FakeUSDC.sol";

contract TestScript is Script {
    FakeUSDC public usdc;

    uint8 decimals = 6;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        baseUSDCSetUp();

        vm.stopBroadcast();
    }

    function baseUSDCSetUp() public {
        usdc = new FakeUSDC("Fake USDC", "USDC", decimals);
    }
}


