#!/bin/zsh

check_numeric() {
  for arg in "$@"; do
    if ! [[ "$arg" =~ ^[0-9]+$ ]]; then
      echo "[*]ERROR: Input '$arg' is not numeric." >&2
      return 1
    fi
  done
  return 0
}

check_empty() {
  local arg=$1
  if [ -z "$arg" ]; then
    echo "[*]ERROR: Missing input."
    return 1
  fi
  return 0
}

listblock() {
    local number=$1
    local hash=$(/*/bitcoin-cli getblockhash $number)
    local block=$(/*/project/local/bin/bitcoin-cli getblock $hash)
    echo $block
    return 0
}

convert_timestamp() {
    local timestamp=$1
    check_empty $timestamp || return 1
    check_numeric "$timestamp" || return 1

    date -d @$timestamp
    return 0
}


get_range_blocks()  {
    local min=$1
    local max=$2
    check_empty $min || return 1
    check_empty $max || return 1
    check_numeric $min || return 1
    check_numeric $max || return 1

    for ((k=min; k<=max; k++)); do
        local v=$(listblock $k)
        local timestamp=$(echo $v | jq ".time")
        local transactions=$(echo $v | jq ".tx")
        echo "[*] BLOCK_TIMESTAMP: $(convert_timestamp $timestamp)\n[*] TRANSACTIONS: $transactions\n"
    done
}

get_single_block() {
    local height=$1
    check_empty "$height" || return 1
    check_numeric "$height" || return 1

    local json_object=$(listblock $height)
    local timestamp=$(echo $json_object | jq ".time")
    echo "[*] BLOCK_TIMESTAMP: $(convert_timestamp $timestamp)\n$json_object"
    return 0
}

get_block_hash() {
    local height=$1
    check_empty $height|| return 1
    check_numeric $height || return 1

    local hash=$(/*/project/local/bin/bitcoin-cli getblockhash $height)
    echo $hash
    return 0
}

get_block_by_hash() {
    local hash=$1
    check_empty $hash || return 1

    local block=$(/*/project/local/bin/bitcoin-cli getblock $hash)
    echo $block
    return 0
}

get_transactions() {
    # input validation
    local height=$1
    check_empty $height || return 1
    check_numeric $height || return 1

    # extract transactions
    local block=$(listblock $height)
    local transactions=$(echo $block | jq -r ".tx | @tsv")
    local transactions=$(echo $block | jq -r ".tx")

    # return them
    echo $transactions
    return 0
}

get_transaction_by_hash() {
    # input validation
    local transaction_hash=$1
    local block_hash=$2
    check_empty $transaction_hash || return 1

    local tx=$(/*/project/local/bin/bitcoin-cli getrawtransaction $transaction_hash true $block_hash )

    echo $tx
    return 0
}

save_json() {
    local min=$1
    local max=$2

    check_empty $min
    check_numeric $min || return 1
    check_numeric $max || return 1

    for ((k=$min; k<=max; k++)); do
        listblock $k >> "/*/dataset/$k.json"
    done
}
