use array::SpanTrait;
use array::ArrayTrait;
use box::BoxTrait;
use ecdsa::check_ecdsa_signature;
use serde::ArraySerde;
use starknet::get_tx_info;
use starknet::get_caller_address;
use starknet::get_contract_address;
use starknet::SyscallResultTrait;
use option::OptionTrait;
use zeroable::Zeroable;
use multicalls::interfaces::Call;

fn execute_calls(mut calls: Array<Call>) -> Array<Span<felt252>> {
    let mut res = ArrayTrait::new();
    loop {
        match calls.pop_front() {
            Option::Some(call) => {
                let _res = execute_single_call(call);
                res.append(_res);
            },
            Option::None(_) => {
                break ();
            },
        };
    };
    res
}

fn execute_single_call(call: Call) -> Span<felt252> {
    let Call{to, selector, calldata } = call;
    starknet::call_contract_syscall(to, selector, calldata.span()).unwrap_syscall()
}
