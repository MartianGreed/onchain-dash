use starknet::ContractAddress;

pub const WORLD_GLOBAL_COUNTER_KEY: u32 = 9999999;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct GlobalCounter {
    #[key]
    global_counter_key: u32,
    pub counter: felt252,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct CallerCounter {
    #[key]
    pub caller: ContractAddress,
    pub counter: felt252,
}

#[derive(Drop, Serde)]
#[dojo::model]
pub struct Messages {
    #[key]
    global_message_key: u32,
    pub messages: Array<Message>,
}

#[derive(Serde, Drop, Introspect)]
#[dojo::model]
pub struct Message {
    #[key]
    pub caller: ContractAddress,
    pub message: ByteArray,
}
