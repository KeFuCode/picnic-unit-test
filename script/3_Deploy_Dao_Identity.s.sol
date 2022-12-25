pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/dao/pass_card/Identity.sol";

contract TestScript is Script {
    Identity public pi;

    address public admin = 0x8652dcFB185f2b11004Da6A4162c31C704A2BE5F;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        baseIdentitySetUp();

        vm.stopBroadcast();
    }

    function baseIdentitySetUp() public {
        pi = new Identity("0xCreator Identity", "0CI", "ipfs://QmPd1mB1B2tqzFe5QVA9C9i6ADNBqXNajQZfpSazQ5wuR4/", admin);
    }
}
