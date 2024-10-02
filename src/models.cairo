use starknet::ContractAddress;
use traits::Drop;

pub const WORLD_GLOBAL_COUNTER_KEY: u32 = 9999999;
pub const WORLD_THEME_KEY: u32 = 9999999;


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
pub struct Message {
    #[key]
    pub identity: ContractAddress,
    pub content: ByteArray,
    #[key]
    pub timestamp: u64,
}

#[derive(Drop, Serde)]
#[dojo::model]
pub struct Theme {
    #[key]
    theme_key: u32,
    pub value: AvailableTheme,
    pub caller: ContractAddress,
    pub timestamp: u64,
}

#[derive(Drop, Serde, Introspect, PartialEq, Debug)]
#[dojo::model]
enum AvailableTheme {
    Light,
    Dark,
    Dojo,
}

impl AvailableThemeIntoFelt252 of core::traits::Into<AvailableTheme, felt252> {
    #[inline]
    fn into(self: AvailableTheme) -> felt252 {
        match self {
            AvailableTheme::Light => 'light',
            AvailableTheme::Dark => 'dark',
            AvailableTheme::Dojo => 'dojo',
        }
    }
}

impl AvailableThemeIntoU8 of core::traits::Into<AvailableTheme, u8> {
    #[inline]
    fn into(self: AvailableTheme) -> u8 {
        match self {
            AvailableTheme::Light => 0,
            AvailableTheme::Dark => 1,
            AvailableTheme::Dojo => 2,
        }
    }
}

impl U8IntoAvailableTheme of core::traits::Into<u8, AvailableTheme> {
    #[inline]
    fn into(self: u8) -> AvailableTheme {
        let card: felt252 = self.into();
        match card {
            0 => AvailableTheme::Light,
            1 => AvailableTheme::Dark,
            2 => AvailableTheme::Dojo,
            _ => AvailableTheme::Light,
        }
    }
}

// impl AvailableThemeEq of core::traits::PartialEq<AvailableTheme> {
//     #[inline]   
//     fn eq(lhs: @AvailableTheme, rhs: @AvailableTheme) -> bool {
//         lhs == rhs
//     }

//     #[inline]
//     fn ne(lhs: @AvailableTheme, rhs: @AvailableTheme) -> bool {
//         lhs != rhs
//     }
// }
