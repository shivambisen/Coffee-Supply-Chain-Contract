#!/bin/bash

# -----------------------------
# CoffeeSupplyChain Test Script
# -----------------------------

# RPC and private key
RPC_URL="http://127.0.0.1:8545"

# run `anvil` to get private key and other test account details
PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
# replace it with your own private key 

# Contract deployed address
# use this command to deploy the contract and get the address
# forge script script/Deploy.s.sol:DeployScript \ --rpc-url http://127.0.0.1:8545 \ --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \ --broadcast
CONTRACT_ADDRESS="0x5FbDB2315678afecb367f032d93F642f64180aa3"
# replace it with your own deployed contract address

# Testing account (must match private key)
TEST_ACCOUNT="0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
# replace it with your own test account address


# dont change the below commands 

# -----------------------------
# Stage Enum Values
# -----------------------------
STAGE_HARVESTED=0
STAGE_CURED=1
STAGE_MILLED=2
STAGE_ROASTED=3
STAGE_PACKAGED=4
STAGE_DISTRIBUTED=5

# -----------------------------
# Start test flow
# -----------------------------
echo "🔹 Starting CoffeeSupplyChain test flow"

# Grant FARMER_ROLE to test account
echo "Granting FARMER_ROLE..."
cast send $CONTRACT_ADDRESS \
"grantRoleTo(address,bytes32)" \
$TEST_ACCOUNT \
$(cast keccak "FARMER_ROLE") \
--private-key $PRIVATE_KEY \
--rpc-url $RPC_URL

# Mint a new batch NFT
echo "Minting a new batch NFT..."
cast send $CONTRACT_ADDRESS \
"mintBatch(address,string,string,string,uint256,address)" \
$TEST_ACCOUNT \
"Chikmagalur, Karnataka" \
"Arabica - SLN" \
"ipfs://QmHarvest" \
0 \
$TEST_ACCOUNT \
--private-key $PRIVATE_KEY \
--rpc-url $RPC_URL

# Hardcode batch ID for testing (first mint on fresh chain)
BATCH_ID=1
echo "✅ Minted batch with ID: $BATCH_ID"

# -----------------------------
# Append stages
# -----------------------------
echo "Appending stage Cured..."
cast send $CONTRACT_ADDRESS \
"appendStage(uint256,uint8,string)" \
$BATCH_ID \
$STAGE_CURED \
"ipfs://QmCured" \
--private-key $PRIVATE_KEY \
--rpc-url $RPC_URL

echo "Appending stage Milled..."
cast send $CONTRACT_ADDRESS \
"appendStage(uint256,uint8,string)" \
$BATCH_ID \
$STAGE_MILLED \
"ipfs://QmMilled" \
--private-key $PRIVATE_KEY \
--rpc-url $RPC_URL

echo "Appending stage Roasted..."
cast send $CONTRACT_ADDRESS \
"appendStage(uint256,uint8,string)" \
$BATCH_ID \
$STAGE_ROASTED \
"ipfs://QmRoasted" \
--private-key $PRIVATE_KEY \
--rpc-url $RPC_URL

echo "Appending stage Packaged..."
cast send $CONTRACT_ADDRESS \
"appendStage(uint256,uint8,string)" \
$BATCH_ID \
$STAGE_PACKAGED \
"ipfs://QmPackaged" \
--private-key $PRIVATE_KEY \
--rpc-url $RPC_URL

echo "Appending stage Distributed..."
cast send $CONTRACT_ADDRESS \
"appendStage(uint256,uint8,string)" \
$BATCH_ID \
$STAGE_DISTRIBUTED \
"ipfs://QmDistributed" \
--private-key $PRIVATE_KEY \
--rpc-url $RPC_URL

# -----------------------------
# Fetch batch core info
# -----------------------------
echo "Fetching batch core info..."
cast call $CONTRACT_ADDRESS \
"getBatchCore(uint256)(tuple(uint256,string,string,address,uint256,uint8))" \
$BATCH_ID \
--rpc-url $RPC_URL

# Fetch batch history
echo "Fetching batch history..."
cast call $CONTRACT_ADDRESS \
"getHistory(uint256)(tuple(uint8,string,uint256,address)[])" \
$BATCH_ID \
--rpc-url $RPC_URL

echo "🔹 CoffeeSupplyChain test flow completed"
