// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/CoffeeSupplyChain.sol";

contract DeployScript is Script {
    function run() public {
        vm.startBroadcast();

        CoffeeSupplyChain c = new CoffeeSupplyChain("CoffeeBatchToken", "COFFEE");
        // After deploy, you can grant roles using c.grantRoleTo(...)
        // Example: c.grantRoleTo(yourAddress, c.FARMER_ROLE());

        vm.stopBroadcast();
    }
}
