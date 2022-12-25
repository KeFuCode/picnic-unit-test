pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/dao/token/Point.sol";

contract TestScript is Script {
    Point public pp;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        basePointSetUp();

        vm.stopBroadcast();
    }

    function basePointSetUp() public {
        pp = new Point("0xCreator Buidl Token", "CBT");
    }
}
