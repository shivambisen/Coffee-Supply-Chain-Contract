// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../lib/types/BatchTypes.sol";

/// @title CoffeeSupplyChain
/// @notice NFT-based batch tokens with role-protected stage appends and immutable history
contract CoffeeSupplyChain is ERC721URIStorage, AccessControl, Ownable {
    using Counters for Counters.Counter;
    using BatchTypes for *;

    Counters.Counter private _batchIdCounter;

    // Roles
    bytes32 public constant FARMER_ROLE     = keccak256("FARMER_ROLE");
    bytes32 public constant CURER_ROLE      = keccak256("CURER_ROLE");
    bytes32 public constant MILLER_ROLE     = keccak256("MILLER_ROLE");
    bytes32 public constant ROASTER_ROLE    = keccak256("ROASTER_ROLE");
    bytes32 public constant PACKAGER_ROLE   = keccak256("PACKAGER_ROLE");
    bytes32 public constant DISTRIBUTOR_ROLE= keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant PAUSER_ROLE     = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE     = keccak256("MINTER_ROLE"); // optional separate minter

    // Batch core metadata
    mapping(uint256 => BatchTypes.BatchCore) private _batches;

    // History per tokenId: sequence of StageRecords
    mapping(uint256 => BatchTypes.StageRecord[]) private _history;

    // Events
    event BatchMinted(uint256 indexed batchId, address indexed farmer, string origin, string variety, string ipfsHash);
    event StageAppended(uint256 indexed batchId, BatchTypes.Stage stage, address indexed actor, string ipfsHash);
    event BatchBurned(uint256 indexed batchId, address indexed actor);

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        // admin setup: deployer gets DEFAULT_ADMIN_ROLE and all managerial roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(FARMER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(CURER_ROLE, msg.sender);
        _grantRole(MILLER_ROLE, msg.sender);
        _grantRole(ROASTER_ROLE, msg.sender);
        _grantRole(PACKAGER_ROLE, msg.sender);
        _grantRole(DISTRIBUTOR_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        transferOwnership(msg.sender);
    }

    /// -------------------------
    /// Batch minting & helpers
    /// -------------------------
    /// @notice Mint a new batch token. Usually called by a FARMER (or MINTER).
    /// @param to recipient of the NFT (commonly farmer address)
    /// @param origin textual origin (e.g., "Chikmagalur, Karnataka")
    /// @param variety cultivar/variety (e.g., "Arabica - SLN")
    /// @param initialMetadataIpfs ipfs hash / metadata pointer for harvest info
    function mintBatch(
        address to,
        string calldata origin,
        string calldata variety,
        string calldata initialMetadataIpfs,
        uint256 harvestTimestamp,
        address farmerAddr
    ) external returns (uint256) {
        require(hasRole(MINTER_ROLE, msg.sender) || hasRole(FARMER_ROLE, msg.sender) || owner() == msg.sender,
            "Not authorized to mint");

        _batchIdCounter.increment();
        uint256 newId = _batchIdCounter.current();

        // store core batch info
        _batches[newId] = BatchTypes.BatchCore({
            batchId: newId,
            origin: origin,
            variety: variety,
            farmer: farmerAddr == address(0) ? to : farmerAddr,
            harvestTimestamp: harvestTimestamp == 0 ? block.timestamp : harvestTimestamp,
            currentStage: BatchTypes.Stage.Harvested
        });

        // mint NFT and optionally set tokenURI to an IPFS pointer for overall metadata
        _safeMint(to, newId);
        if (bytes(initialMetadataIpfs).length > 0) {
            _setTokenURI(newId, initialMetadataIpfs);
        }

        // push initial history record (Harvested)
        _history[newId].push(BatchTypes.StageRecord({
            stage: BatchTypes.Stage.Harvested,
            metadataIpfsHash: initialMetadataIpfs,
            timestamp: block.timestamp,
            actor: msg.sender
        }));

        emit BatchMinted(newId, _batches[newId].farmer, origin, variety, initialMetadataIpfs);
        return newId;
    }

    /// -------------------------
    /// Append stage data
    /// -------------------------
    /// @notice Append a new stage record. Only the address holding the proper role can append for its stage.
    /// @dev Must progress to a higher stage. Can't rewrite history.
    /// @param batchId token id / batch id
    /// @param stage the stage to append
    /// @param metadataIpfsHash IPFS pointer with stage-specific metadata (drying log, moisture readings, roast profile, shipment manifest etc.)
    function appendStage(
        uint256 batchId,
        BatchTypes.Stage stage,
        string calldata metadataIpfsHash
    ) external {
        require(_exists(batchId), "Batch does not exist");
        require(uint8(stage) > 0, "Invalid stage");
        BatchTypes.BatchCore storage core = _batches[batchId];
        BatchTypes.Stage current = core.currentStage;

        // require monotonic stage progression (allow equal? here require strictly increasing)
        require(uint8(stage) > uint8(current), "Stage must progress forward");

        // role checks per stage
        if (stage == BatchTypes.Stage.Cured) {
            require(hasRole(CURER_ROLE, msg.sender), "Not a curer");
        } else if (stage == BatchTypes.Stage.Milled) {
            require(hasRole(MILLER_ROLE, msg.sender), "Not a miller");
        } else if (stage == BatchTypes.Stage.Roasted) {
            require(hasRole(ROASTER_ROLE, msg.sender), "Not a roaster");
        } else if (stage == BatchTypes.Stage.Packaged) {
            require(hasRole(PACKAGER_ROLE, msg.sender), "Not a packager");
        } else if (stage == BatchTypes.Stage.Distributed) {
            require(hasRole(DISTRIBUTOR_ROLE, msg.sender), "Not a distributor");
        } else {
            revert("Append not authorized for this stage");
        }

        // append history as immutable record
        _history[batchId].push(BatchTypes.StageRecord({
            stage: stage,
            metadataIpfsHash: metadataIpfsHash,
            timestamp: block.timestamp,
            actor: msg.sender
        }));

        // update core current stage
        core.currentStage = stage;

        // Optionally update tokenURI to the latest metadata pointer (or keep original)
        if (bytes(metadataIpfsHash).length > 0) {
            _setTokenURI(batchId, metadataIpfsHash);
        }

        emit StageAppended(batchId, stage, msg.sender, metadataIpfsHash);
    }

    /// -------------------------
    /// View helpers / getters
    /// -------------------------
    function getBatchCore(uint256 batchId) public view returns (BatchTypes.BatchCore memory) {
        require(_exists(batchId), "Batch does not exist");
        return _batches[batchId];
    }

    /// @notice returns full history (ordered) for the batch
    function getHistory(uint256 batchId) external view returns (BatchTypes.StageRecord[] memory) {
        require(_exists(batchId), "Batch does not exist");
        return _history[batchId];
    }

    /// -------------------------
    /// Role & admin helpers
    /// -------------------------
    /// @notice grant a stage role to an address
    function grantRoleTo(address roleHolder, bytes32 role) external {
        // only default admin or owner may call (AccessControl checks DEFAULT_ADMIN_ROLE)
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || owner() == msg.sender, "Not admin");
        _grantRole(role, roleHolder);
    }

    /// @notice revoke a stage role
    function revokeRoleFrom(address roleHolder, bytes32 role) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || owner() == msg.sender, "Not admin");
        _revokeRole(role, roleHolder);
    }

    /// -------------------------
    /// Overrides for safety / transfer events
    /// -------------------------
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override {
        super._beforeTokenTransfer(from, to, tokenId);
        // you can hook in custody changes here (emit extra logs), but ERC721 transfer already signals ownership change
    }

    /// @notice allows admin to burn a token (e.g., QA / recall) — recorded by event
    function burn(uint256 tokenId) external {
        require(_exists(tokenId), "Batch does not exist");
        require(owner() == msg.sender || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Not authorized to burn");
        _burn(tokenId);
        delete _batches[tokenId];
        delete _history[tokenId];
        emit BatchBurned(tokenId, msg.sender);
    }
}
