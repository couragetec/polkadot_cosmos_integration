#!/bin/bash

#! This test runs one node of the substarte and corresponding to it one cosmos node
#! 1. Set up 1 cosmos validators using the `nsd tx staking create-validator` command.
#! 2. Check that cosmos account jack does not have any rewards from the cosmos validator which his delegates.
#! 3. Match fist cosmos validator to the substarte validator Bob, so as a result we expect that susbrate will change the validator list to the one Bob
#! 4. Check that cosmos account jack has rewards from the cosmos validator which his delegates.

trap "exit" INT TERM ERR
trap "kill 0" EXIT

expect_validators_set_1="5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY@5FHneW46xGXgs5mUiveU4sbTyGBzmstUspZC92UhjJM694ty"
expect_validators_set_2="5FHneW46xGXgs5mUiveU4sbTyGBzmstUspZC92UhjJM694ty"
expect_validators_set_3="5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY"

cosmos_validator_pub_key="0xa4f588be5bd917c0933d6fe1ac18d05b25dd5b27890327a57b9137b986736f15"

source ./testing_setup/basic_setup.sh
source ./testing_setup/test_utils.sh

start_all
sleep 20s

simd tx staking create-validator \
 --amount=10000000stake \
 --pubkey=cosmosvalconspub1zcjduepq5n6c30jmmytupyeadls6cxxstvja6ke83ypj0ftmjymmnpnndu2s0793yf \
 --moniker="alex validator" \
 --chain-id=test_chain \
 --from=jack \
 --commission-rate="0.10" \
 --commission-max-rate="0.20" \
 --commission-max-change-rate="0.01" \
 --min-self-delegation="1" \
 --gas-prices="0.025stake" \
 -y

cd ../../node_testing_ui

validators_set=$(node ./get-validators.app.js)
assert_eq "$validators_set" $expect_validators_set_1

sleep 30s

value=$(simd q bank balances $(simd keys show jack -a))
echo "$value"
expected=$'balances:\n- amount: \"89995000\"\n  denom: stake\npagination:\n  next_key: null\n  total: \"0\"'
assert_eq "$value" "$expected"

# withdraw rewards
simd tx distribution withdraw-all-rewards --chain-id=test_chain --from=$(simd keys show jack -a) -y
sleep 5s

value=$(simd q bank balances $(simd keys show jack -a))
echo "$value"
expected=$'balances:\n- amount: \"89995000\"\n  denom: stake\npagination:\n  next_key: null\n  total: \"0\"'
assert_eq "$value" "$expected"

node ./insert-cosmos-validator.app.js //Bob $cosmos_validator_pub_key
sleep 30s

# withdraw rewards
simd tx distribution withdraw-all-rewards --chain-id=test_chain --from=$(simd keys show jack -a) -y
sleep 5s

value=$(simd q bank balances $(simd keys show jack -a))
echo "$value"
expected=$'balances:\n- amount: \"89995000\"\n  denom: stake\npagination:\n  next_key: null\n  total: \"0\"'
assert_ne "$value" "$expected"

test_passed "cosmos_validator_rewards_test test passed"