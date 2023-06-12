use array::ArrayTrait;
use result::ResultTrait;
use starknet::ContractAddress;
use starknet::contract_address_const;
use composable_multicall::interfaces::Call;
use composable_multicall::default_multicall::_execute_calls;
use core::traits::Into;

const TRANSFER_SELECTOR: felt252 = 0x83afd3f4caedc6eebf44246fe54e38c95e3179a5ec9ea81740eca5b482d12e;

#[test]
fn test_multicall() {

    let naming_contract = contract_address_const::<0x003bab268e932d2cecd1946f100ae67ce3dff9fd234119ea2f6da57d16d29fce>();
    let eth_contract = contract_address_const::<0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7>();
    let mut calls = ArrayTrait::new();

    // Craft call1
    let mut calldata1 = ArrayTrait::new();
    // [ grom ] .stark
    calldata1.append(1);
    calldata1.append(679332);
    let call1 = Call {
        to: naming_contract, selector: 'domain_to_address', calldata: calldata1
    };

    // Craft call2

    let mut calldata2 = ArrayTrait::new();
    let amount2: u256 = 500;
    calldata2.append(0x00a00373A00352aa367058555149b573322910D54FCDf3a926E3E56D0dCb4b0c);
    calldata2.append(amount2.low.into());
    calldata2.append(amount2.high.into());
    let call2 = Call {
        to: eth_contract, selector: TRANSFER_SELECTOR, calldata: calldata2
    };

    // Bundle calls and exeute
    calls.append(call1);
    calls.append(call2);

    _execute_calls(calls);
}
