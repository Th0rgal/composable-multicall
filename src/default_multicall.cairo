use array::SpanTrait;
use array::ArrayTrait;
use core::traits::PartialEq;
use box::BoxTrait;
use ecdsa::check_ecdsa_signature;
use serde::ArraySerde;
use starknet::get_tx_info;
use starknet::get_caller_address;
use starknet::get_contract_address;
use starknet::SyscallResultTrait;
use option::OptionTrait;
use zeroable::Zeroable;
use composable_multicall::interfaces::Call;

fn _execute_calls(mut calls: Array<Call>) -> Array<Span<felt252>> {
    let mut res = ArrayTrait::new();
    loop {
        match calls.pop_front() {
            Option::Some(call) => {
                let Call{to, selector, calldata } = call;
                compile_calldata(calldata.span());
                let _res = starknet::call_contract_syscall(to, selector, calldata.span())
                    .unwrap_syscall();
                res.append(_res);
            },
            Option::None(_) => {
                break ();
            },
        };
    };
    res
}

fn compile_calldata(mut calldata: Span<felt252>) {
    match calldata.pop_front() {
        Option::Some(felt) => {
                if *felt == 0 {

                }
            }
        },
        Option::None(_) => {},
    };
}
