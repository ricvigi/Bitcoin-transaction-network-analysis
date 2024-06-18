#!/bin/zsh

function get_transaction_by_hash {
  # input validation
  local transaction_hash=$1
  local block_hash=$2
  check_empty $transaction_hash || return 1

  local tx=$(/home/rick/Ri/SecondYear/2ndSemester/DMAU2/project/local/bin/bitcoin-cli getrawtransaction $transaction_hash true $block_hash )

  echo $tx
  return 0
}

function get_transaction_with_API {
  local tx_hash=$1
  check_empty $tx_hash || return 1
  #local tx=$(curl https://blockchain.info/rawtx/$tx_hash\?format=hex)
  local tx=$(curl https://blockchain.info/rawtx/$tx_hash)
  echo $tx
}

function check_empty {
  local arg=$1
  if [ -z "$arg" ]; then
    echo "[*]ERROR: Missing input."
    return 1
  fi
  return 0
}

# Use this if you want to save it to a file
#get_transaction_by_hash $1 $2 >> $1.json
#get_transaction_by_hash $1 $2
get_transaction_with_API $1
