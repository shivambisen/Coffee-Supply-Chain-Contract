// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title BatchTypes
/// @notice Shared enums/structs used by the main contract
library BatchTypes {
    enum Stage {
        None,       // 0 - initial/unused
        Harvested,  // 1 - farmer
        Cured,      // 2 - drying/curing vendor
        Milled,     // 3 - milling/hulling
        Roasted,    // 4 - roasting facility
        Packaged,   // 5 - packaging
        Distributed // 6 - distribution/retailer
    }

    struct StageRecord {
        Stage stage;
        string metadataIpfsHash; // IPFS hash or pointer (e.g., "ipfs://Qm...")
        uint256 timestamp;
        address actor; // who appended this stage (msg.sender)
    }

    struct BatchCore {
        uint256 batchId;
        string origin;    // textual origin (region/farm)
        string variety;   // variety/cultivar
        address farmer;   // initial farmer address
        uint256 harvestTimestamp;
        Stage currentStage;
    }
}
