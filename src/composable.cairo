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
use multicalls::interfaces::Call;
use traits::{Into, TryInto};

fn execute_calls(mut calls: Array<Call>) -> Array<Span<felt252>> {
    let mut res = ArrayTrait::new();
    loop {
        match calls.pop_front() {
            Option::Some(call) => {
                let Call{to, selector, calldata } = call;
                let compiled_calldata = compile_calldata(res.span(), calldata.span());
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

fn compile_calldata(res: Span<Span<felt252>>, mut calldata: Span<felt252>) -> Array<felt252> {
    match calldata.pop_front() {
        Option::Some(felt) => {
            let mut output_calldata = (if *felt == 0 {
                *calldata.pop_front().expect('expected a felt after prefix 0')
            } else if *felt == 1 {
                *(*(res
                    .get(
                        (*calldata.pop_front().expect('expected a felt after prefix 1'))
                            .try_into()
                            .expect('invalid call_id value')
                    )
                    .expect('no call found for this call_id')
                    .unbox()))
                    .get(
                        (*calldata.pop_front().expect('expected 2 felts after prefix 1'))
                            .try_into()
                            .expect('invalid value_id value')
                    )
                    .expect('no felt found at this value_id')
                    .unbox()
            } else {
                panic_with_felt252('unexpected prefix')
            });
            compile_calldata(res, calldata);
            ArrayTrait::new()
        },
        Option::None(_) => ArrayTrait::new(),
    }
}
