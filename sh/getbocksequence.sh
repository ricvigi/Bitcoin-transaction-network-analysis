#!/bin/zsh
# This script queries the blockchain for a range of blocks (from height a to height b) and saves each block as a json file

# Input validation function
check_numeric() {
  for arg in "$@"; do
    if ! [[ "$arg" =~ ^[0-9]+$ ]]; then
      echo "[*]ERROR: Input '$arg' is not numeric." >&2
      return 1
    fi
  done
  return 0
}

# Input validation function
check_empty() {
  local arg=$1
  if [ -z "$arg" ]; then
    echo "[*]ERROR: Missing input."
    return 1
  fi
  return 0
}

# Query the blockchain for a block
listblock() {
    check_numeric $1 || return 1
    local number=$1
    local hash=$(/home/rick/Ri/SecondYear/2ndSemester/DMAU2/project/local/bin/bitcoin-cli getblockhash $number)
    local block=$(/home/rick/Ri/SecondYear/2ndSemester/DMAU2/project/local/bin/bitcoin-cli getblock $hash)
    echo $block
    return 0
}

# Loop over a range of block heights
for height in {$1..$2}; do
    #curl https://blockchain.info/block-height/$height\?format=json | jq . >> bigsequence/$height.json # blockchain.info API. Returns a heavier JSON object than calling bitcoin-cli
    listblock $height >> bigsequence/$height.json
    echo "[_]BLOCK '$height' correctly downloaded";
    done
