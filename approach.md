# ☕ Coffee Supply Chain – README

This project demonstrates how to use an **NFT-based supply chain contract** to track coffee production across multiple stages. Each coffee batch is represented by a unique NFT, and its lifecycle is documented with metadata stored on **IPFS**. This ensures **immutability, traceability, and transparency** for every stakeholder.

---


### Start of the Journey

- Every batch of coffee gets a unique ID card (batchId).

- This card tells us where it came from (origin), what type it is (variety), and who the farmer is.

### Step-by-Step Travel

- Coffee goes through different steps before it reaches us:
Harvested → Cured → Milled → Roasted → Packaged → Distributed.

It’s like following a treasure map—you can’t skip steps, you must follow the path in order.

### Secret Notes on IPFS

At every step, someone writes a note (like a report or photo) and hides it safely in a treasure chest (IPFS).

example - 


### Example of Ipfs Metadata of each step

### 1. **Harvested (Farmer)**

* **Purpose:** Record the origin of the coffee, farmer details, and harvest conditions.
* Example IPFS JSON:

```json
{
  "stage": "Harvested",
  "batchId": 1,
  "farmerName": "Ramesh Gowda",
  "farmerWallet": "0xFARMER_ADDRESS",
  "farmLocation": "Chikmagalur, Karnataka, India",
  "variety": "Arabica - SLN",
  "harvestDate": "2025-09-15",
  "harvestConditions": {
    "altitude": "1100m",
    "shade": true,
    "method": "Hand-picked"
  },
  "documents": ["ipfs://QmSoilReport", "ipfs://QmRainfallLog"]
}
```

---

### 2. **Cured (Curer)**

* **Purpose:** Drying, curing logs, and quality checks after harvest.
* Example IPFS JSON:

```json
{
  "stage": "Cured",
  "batchId": 1,
  "curerName": "ABC Processing",
  "curerWallet": "0xCURER_ADDRESS",
  "curingDate": "2025-09-20",
  "dryingMethod": "Sun-dried",
  "moistureContent": "11.5%",
  "qualityGrading": "Grade A",
  "documents": ["ipfs://QmMoistureTestReport"]
}
```

---

### 3. **Milled (Miller)**

* **Purpose:** Removal of husk/parchment and preparation for roasting.
* Example IPFS JSON:

```json
{
  "stage": "Milled",
  "batchId": 1,
  "millerName": "XYZ Mills",
  "millerWallet": "0xMILLER_ADDRESS",
  "millingDate": "2025-09-25",
  "method": "Wet milling",
  "outputWeightKg": 950,
  "defectsRemovedPercent": 3.2,
  "documents": ["ipfs://QmMillingCertificate"]
}
```

---

### 4. **Roasted (Roaster)**

* **Purpose:** Record roast profile (critical for flavor).
* Example IPFS JSON:

```json
{
  "stage": "Roasted",
  "batchId": 1,
  "roasterName": "RoastMasters Co.",
  "roasterWallet": "0xROASTER_ADDRESS",
  "roastDate": "2025-09-28",
  "roastProfile": {
    "temperatureCurve": "ipfs://QmTempGraph",
    "roastLevel": "Medium-Dark",
    "durationMinutes": 14
  },
  "cuppingScore": 87,
  "documents": ["ipfs://QmRoastLog"]
}
```

---

### 5. **Packaged (Packager)**

* **Purpose:** Packaging and labeling for retail/export.
* Example IPFS JSON:

```json
{
  "stage": "Packaged",
  "batchId": 1,
  "packagerName": "Coffee Export Ltd.",
  "packagerWallet": "0xPACKAGER_ADDRESS",
  "packagingDate": "2025-09-30",
  "packageSize": "500g",
  "packageType": "Vacuum sealed with nitrogen flush",
  "batchCodes": ["LOT-2025-0915-001"],
  "documents": ["ipfs://QmPackagingSpec"]
}
```

---

### 6. **Distributed (Distributor)**

* **Purpose:** Record logistics, delivery, and destination.
* Example IPFS JSON:

```json
{
  "stage": "Distributed",
  "batchId": 1,
  "distributorName": "Global Coffee Traders",
  "distributorWallet": "0xDISTRIBUTOR_ADDRESS",
  "distributionDate": "2025-10-02",
  "destination": "Berlin, Germany",
  "logisticsProvider": "DHL",
  "shipmentTracking": "DHL-123456789",
  "documents": ["ipfs://QmBillOfLading", "ipfs://QmCustomsClearance"]
}
```



They leave the chest’s key (IPFS hash) on the blockchain, so anyone can open and check it later.

example - ipfs://QmCuringLog, ipfs://QmHarvestInfo

### Who Did What

Each step is signed by the person who did it: farmer, miller, roaster, packager, distributor.

No one can lie, because their blockchain signature (address) is saved forever.

### A Transparent Diary

The blockchain keeps a diary of the coffee’s journey.

For every stage, it records:

What step happened

Where the secret note is (IPFS link)

When it happened (timestamp)

Who did it (actor)

### Always Know the Current Step

At any time, we can ask: “Where is this coffee now?”

The blockchain tells us the current stage (like Packaged or Distributed).




## 📂 Example Batch JSON

```json
{
  "batchCore": {
    "batchId": 1,
    "origin": "Chikmagalur, Karnataka",
    "variety": "Arabica - SLN",
    "farmer": "0xFARMER_ADDRESS",
    "harvestTimestamp": 1726829027,
    "currentStage": "Distributed"
  },
  "history": [
    {
      "stage": "Harvested",
      "metadataIpfsHash": "ipfs://QmHarvestInfo",
      "timestamp": 1726829027,
      "actor": "0xFARMER_ADDRESS"
    },
    {
      "stage": "Cured",
      "metadataIpfsHash": "ipfs://QmCuringLog",
      "timestamp": 1726831000,
      "actor": "0xCURER_ADDRESS"
    },
    {
      "stage": "Milled",
      "metadataIpfsHash": "ipfs://QmMillingReport",
      "timestamp": 1726840000,
      "actor": "0xMILLER_ADDRESS"
    },
    {
      "stage": "Roasted",
      "metadataIpfsHash": "ipfs://QmRoastProfile",
      "timestamp": 1726845000,
      "actor": "0xROASTER_ADDRESS"
    },
    {
      "stage": "Packaged",
      "metadataIpfsHash": "ipfs://QmPackagingDetails",
      "timestamp": 1726850000,
      "actor": "0xPACKAGER_ADDRESS"
    },
    {
      "stage": "Distributed",
      "metadataIpfsHash": "ipfs://QmShippingManifest",
      "timestamp": 1726860000,
      "actor": "0xDISTRIBUTOR_ADDRESS"
    }
  ]
}
```

---

## 🔄 Contract Approach

The contract works as follows:

1. **NFT Minting (Batch Creation)**

   * Each coffee batch is minted as a unique NFT (`batchId`).
   * The NFT links to core metadata: origin, variety, farmer, and initial timestamp.

2. **Stage Updates (Lifecycle Tracking)**

   * Stakeholders (farmer, curer, miller, roaster, packager, distributor) update the NFT with IPFS metadata.
   * Each update is stored on-chain as an event and linked to IPFS.

3. **Immutable History**

   * The batch `history[]` array stores all stages with timestamps, metadata hashes, and actor addresses.
   * This ensures complete provenance for consumers and auditors.

---
