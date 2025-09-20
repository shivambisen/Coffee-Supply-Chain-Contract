// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/CoffeeSupplyChain.sol";

contract DeployScript is Script {
    function run() public {
        vm.startBroadcast(
            0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
        );

        CoffeeSupplyChain c = new CoffeeSupplyChain("CoffeeBatchToken", "COFFEE");

        console2.log("Deployed CoffeeSupplyChain at:", address(c));

        vm.stopBroadcast();
    }
}
