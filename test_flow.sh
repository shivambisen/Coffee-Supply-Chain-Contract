#!/bin/bash

# -----------------------------
# CoffeeSupplyChain Test Script
# -----------------------------

# RPC and private key
RPC_URL="http://127.0.0.1:8545"

# run `anvil` to get private key and other test account details
PRIVATE_KEY="0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d"
# replace it with your own private key 

# Contract deployed address
# use this command to deploy the contract and get the address
# forge script script/Deploy.s.sol:DeployScript \ --rpc-url http://127.0.0.1:8545 \ --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \ --broadcast
CONTRACT_ADDRESS="0x8464135c8F25Da09e49BC8782676a84730C318bC"
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
core=$(cast call $CONTRACT_ADDRESS \
"getBatchCore(uint256)(tuple(uint256,string,string,address,uint256,uint8))" \
$BATCH_ID \
--rpc-url $RPC_URL)

echo "$core"


# Fetch batch history
echo "Fetching batch history..."
history=$(cast call $CONTRACT_ADDRESS \
"getHistory(uint256)(tuple(uint8,string,uint256,address)[])" \
$BATCH_ID \
--rpc-url $RPC_URL)
echo "$history"

# Stage names mapping
stages=(Harvested Cured Milled Roasted Packaged Distributed)

# -------------------------
# Parse core safely using regex
# -------------------------
# Remove parentheses
core_clean=$(echo "$core" | sed -E 's/^\(|\)$//g')

# Extract values with regex
batchId=$(echo "$core_clean" | sed -E 's/^([0-9]+),.*/\1/')
origin=$(echo "$core_clean" | grep -oP '"\K[^"]*(?=")' | sed -n '1p')
variety=$(echo "$core_clean" | grep -oP '"\K[^"]*(?=")' | sed -n '2p')
farmer=$(echo "$core_clean" | sed -E 's/.*(0x[0-9a-fA-F]{40}).*/\1/')
harvestTimestamp=$(echo "$core_clean" | grep -oP '(?<=, )\d{9,10}(?= \[|, [0-9])' | head -n1)
currentStage=$(echo "$core_clean" | grep -oP ',\s*([0-9]+)$' | tr -d ', ')

core_json=$(cat <<EOF
{
  "batchId": $batchId,
  "origin": "$origin",
  "variety": "$variety",
  "farmer": "$farmer",
  "harvestTimestamp": $harvestTimestamp,
  "currentStage": "$currentStage"
}
EOF
)

# -------------------------
# Parse history
# -------------------------
history_json="["
history_entries=$(echo "$history" | sed -E 's/^\[|\]$//g' | sed 's/),/)\n/g')

while read -r entry; do
  entry=$(echo "$entry" | sed -E 's/^\(|\)$//g')
  stageIdx=$(echo "$entry" | awk -F',' '{print $1}')
  ipfsHash=$(echo "$entry" | grep -oP '"\K[^"]*(?=")')
  ts=$(echo "$entry" | awk -F',' '{print $3}' | tr -d ' ')
  actor=$(echo "$entry" | awk -F',' '{print $4}' | tr -d ' ')
  stageName=${stages[$stageIdx]}

  history_json+=$(cat <<EOF
{
  "stage": "$stageName",
  "metadataIpfsHash": "$ipfsHash",
  "timestamp": $ts,
  "actor": "$actor"
},
EOF
)
done <<< "$history_entries"

# Remove trailing comma and close array
history_json=$(echo "$history_json" | sed '$ s/,$//')
history_json+="]"

# -------------------------
# Save JSON
# -------------------------
json_file="batch_${BATCH_ID}.json"
cat <<EOF > "$json_file"
{
  "core": $core_json,
  "history": $history_json
}
EOF

echo "✅ Saved structured JSON to $json_file"



