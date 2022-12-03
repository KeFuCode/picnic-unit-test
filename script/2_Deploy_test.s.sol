pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import "forge-std/console.sol";

contract TestScript is Script {

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        console.logAddress(address(this));

        vm.stopBroadcast();
    }
}