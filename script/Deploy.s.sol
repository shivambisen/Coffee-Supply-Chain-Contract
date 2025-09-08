// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/CoffeeSupplyChain.sol";

contract DeployScript is Script {
    function run() public {
        vm.startBroadcast(
            0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
        );

        CoffeeSupplyChain c = new CoffeeSupplyChain("CoffeeBatchToken", "COFFEE");

        console2.log("Deployed CoffeeSupplyChain at:", address(c));

        vm.stopBroadcast();
    }
}
