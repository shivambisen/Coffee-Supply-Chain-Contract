// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/CoffeeSupplyChain.sol";
import "../src/types/BatchTypes.sol";

contract CoffeeSupplyChainTest is Test {
    CoffeeSupplyChain coffee;

    address farmer      = address(1);
    address curer       = address(2);
    address miller      = address(3);
    address roaster     = address(4);
    address packager    = address(5);
    address distributor = address(6);

    function setUp() public {
        coffee = new CoffeeSupplyChain("CoffeeBatch", "COF");

        // Grant roles
        vm.startPrank(coffee.owner());
        coffee.grantRoleTo(farmer, coffee.FARMER_ROLE()); // Ensure FARMER_ROLE is defined in CoffeeSupplyChain
        coffee.grantRoleTo(curer, coffee.CURER_ROLE());
        coffee.grantRoleTo(miller, coffee.MILLER_ROLE());
        coffee.grantRoleTo(roaster, coffee.ROASTER_ROLE());
        coffee.grantRoleTo(packager, coffee.PACKAGER_ROLE());
        coffee.grantRoleTo(distributor, coffee.DISTRIBUTOR_ROLE());
        vm.stopPrank();
    }

    function testMintBatch() public {
        vm.startPrank(farmer);
        uint256 batchId = coffee.mintBatch(
            farmer,
            "Chikmagalur",
            "Arabica",
            "ipfs://harvest-metadata",
            block.timestamp,
            farmer
        );
        vm.stopPrank();

        BatchTypes.BatchCore memory core = coffee.getBatchCore(batchId);
        assertEq(core.origin, "Chikmagalur");
        assertEq(uint8(core.currentStage), uint8(BatchTypes.Stage.Harvested));
    }

    function testAppendStage() public {
        // Mint
        vm.startPrank(farmer);
        uint256 batchId = coffee.mintBatch(farmer, "Coorg", "Robusta", "ipfs://harvest", 0, farmer);
        vm.stopPrank();

        // Append curing
        vm.startPrank(curer);
        coffee.appendStage(batchId, BatchTypes.Stage.Cured, "ipfs://cured");
        vm.stopPrank();

        BatchTypes.BatchCore memory core = coffee.getBatchCore(batchId);
        assertEq(uint8(core.currentStage), uint8(BatchTypes.Stage.Cured));
    }

    function testFullLifecycle() public {
        vm.startPrank(farmer);
        uint256 batchId = coffee.mintBatch(farmer, "Kenya", "SL28", "ipfs://harvest", 0, farmer);
        vm.stopPrank();

        vm.prank(curer);
        coffee.appendStage(batchId, BatchTypes.Stage.Cured, "ipfs://cured");

        vm.prank(miller);
        coffee.appendStage(batchId, BatchTypes.Stage.Milled, "ipfs://milled");

        vm.prank(roaster);
        coffee.appendStage(batchId, BatchTypes.Stage.Roasted, "ipfs://roasted");

        vm.prank(packager);
        coffee.appendStage(batchId, BatchTypes.Stage.Packaged, "ipfs://packaged");

        vm.prank(distributor);
        coffee.appendStage(batchId, BatchTypes.Stage.Distributed, "ipfs://distributed");

        BatchTypes.BatchCore memory core = coffee.getBatchCore(batchId);
        assertEq(uint8(core.currentStage), uint8(BatchTypes.Stage.Distributed));

        // Verify full history
        BatchTypes.StageRecord[] memory hist = coffee.getHistory(batchId);
        assertEq(hist.length, 6); // Harvested + 5 appended stages
    }
}
