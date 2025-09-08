# CoffeeSupplyChain ☕️

## Overview

The **CoffeeSupplyChain** smart contract is an end-to-end tracking and tokenization system for coffee supply chains, built on Ethereum using Solidity. It leverages **ERC721 Non-Fungible Tokens (NFTs)** to represent unique batches of coffee beans, ensuring transparency, authenticity, and traceability from farm to consumer.

The contract combines:

* **ERC721URIStorage**: To mint NFTs that represent unique coffee batches.
* **AccessControl**: To manage roles (farmer, roaster, distributor, retailer, and consumer).
* **Custom supply chain logic**: To define the lifecycle of coffee batches.

---

## Features

* Minting NFTs for each coffee batch with metadata.
* Role-based permissions:

  * **Farmer**: Creates new coffee batch NFTs.
  * **Roaster**: Updates roasting details.
  * **Distributor**: Manages logistics and shipping.
  * **Retailer**: Marks batches for sale.
  * **Consumer**: Can purchase and verify coffee batch NFTs.
* Lifecycle tracking:

  * Farm ➝ Roaster ➝ Distributor ➝ Retailer ➝ Consumer
* Metadata storage (IPFS/JSON URI) for transparency.

---

## Contract Flow Example

### 1. Farmer creates a batch

```solidity
coffeeSupplyChain.mintBatch(farmerAddress, "ipfs://QmBatchMetadataHash");
```

* Mints a new NFT for the coffee batch.
* Links metadata stored in IPFS (origin, harvest date, quality details).

### 2. Roaster updates batch

```solidity
coffeeSupplyChain.updateRoasting(batchId, "Medium Roast", "2025-09-01");
```

* Adds roasting information to the batch.

### 3. Distributor ships batch

```solidity
coffeeSupplyChain.updateDistribution(batchId, "Shipment #12345", "2025-09-03");
```

* Marks the logistics details of the batch.

### 4. Retailer lists for sale

```solidity
coffeeSupplyChain.updateRetail(batchId, "CoffeeHouse Store", 20 ether);
```

* Sets retail store and price.

### 5. Consumer purchases

```solidity
coffeeSupplyChain.purchaseBatch{value: 20 ether}(batchId);
```

* Transfers NFT ownership to the consumer.
* Marks the batch as consumed.

---

## Roles

* `DEFAULT_ADMIN_ROLE`: Can assign/revoke roles.
* `FARMER_ROLE`: Creates new coffee batches.
* `ROASTER_ROLE`: Updates roasting information.
* `DISTRIBUTOR_ROLE`: Updates distribution/shipping details.
* `RETAILER_ROLE`: Lists coffee for sale.
* `CONSUMER_ROLE`: Purchases coffee.

---

## Example Metadata (IPFS JSON)

```json
{
  "name": "Ethiopian Arabica Coffee Batch #001",
  "description": "Single origin coffee beans harvested in Ethiopia, 2025 season.",
  "origin": "Yirgacheffe, Ethiopia",
  "harvest_date": "2025-08-15",
  "roast": "Medium",
  "distributor": "Global Coffee Logistics",
  "retailer": "CoffeeHouse Store",
  "price": "20 ETH"
}
```

---

## How to Test

### 1. Install Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 2. Build contract

```bash
forge build
```

### 3. Run tests

```bash
forge test
```

### 4. Deploy locally

```bash
anvil
```

Then, read test script first and add your credentials locally

after replacing with your address run 

```bash
 chmod +x ./test_flow.sh
```

---

## Future Enhancements

* Integration with **oracles** for real-world logistics.
* Consumer-facing dApp for batch scanning.
* Expanded metadata (sustainability metrics, certifications).
* Multi-chain deployment for scalability.

---

## License

MIT License © 2025 Shivam Bisen
