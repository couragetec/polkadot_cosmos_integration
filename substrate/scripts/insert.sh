#!/usr/bin/env bash

set -e

echo "*** Inserting key ***"

function insert {
    curl "http://localhost:${1}" -H "Content-Type:application/json;charset=utf-8" -d '{ "jsonrpc":"2.0", "id":1, "method":"author_insertKey", "params": ["${2}", "${3}", "${4}"] }';
}

insert "9933" "abci" "again cinnamon mesh post loop strike this equip door metal exhibit collect" "0x0913a0136221cdd32a760591366a7de950f0ed658c00087a4f2e2b16c82df6a0"
