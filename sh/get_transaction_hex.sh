#!/bin/zsh

function get_transaction_with_API {
  local tx_hash=$1
  check_empty $tx_hash || return 1
  local tx=$(curl https://blockchain.info/rawtx/$tx_hash\?format=hex)
  #local tx=$(curl https://blockchain.info/rawtx/$tx_hash)
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

get_transaction_with_API $1
