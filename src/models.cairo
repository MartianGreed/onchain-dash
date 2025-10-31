use starknet::ContractAddress;
use core::byte_array::ByteArray;
use core::serde::Serde;
use dojo::storage::dojo_store::DojoStore;
use dojo::utils::default_address;

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
    pub timestamp: Option<u64>,
}

#[derive(Drop, Serde)]
#[dojo::model]
pub struct Message {
    #[key]
    pub identity: ContractAddress,
    #[key]
    pub timestamp: u64,
    pub content: ByteArray,
}

#[derive(Copy, Drop, Serde, Introspect, PartialEq)]
#[dojo::model]
pub struct Theme {
    #[key]
    theme_key: u32,
    pub value: felt252,
    pub caller: ContractAddress,
    pub timestamp: u64,
}

#[derive(Drop, Serde, Copy, Introspect, PartialEq)]
pub enum DashboardTheme {
    Predefined: AvailableTheme,
    Custom: CustomTheme,
}

#[derive(Drop, Serde, Copy, Introspect, PartialEq)]
pub enum AvailableTheme {
    Light,
    Dark,
    Dojo,
}

#[derive(Drop, Serde, Copy, Introspect, PartialEq)]
pub struct CustomTheme {
    pub classname: felt252,
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

impl DashboardThemeDojoStore of DojoStore<DashboardTheme> {
    fn dojo_serialize(self: @DashboardTheme, ref serialized: Array<felt252>) {
        Serde::serialize(self, ref serialized);
    }

    fn dojo_deserialize(ref values: Span<felt252>) -> Option<DashboardTheme> {
        Serde::<DashboardTheme>::deserialize(ref values)
    }
}

impl AvailableThemeDojoStore of DojoStore<AvailableTheme> {
    fn dojo_serialize(self: @AvailableTheme, ref serialized: Array<felt252>) {
        Serde::serialize(self, ref serialized);
    }

    fn dojo_deserialize(ref values: Span<felt252>) -> Option<AvailableTheme> {
        Serde::<AvailableTheme>::deserialize(ref values)
    }
}

pub fn theme_with_value(
    theme_key: u32, value: felt252, caller: ContractAddress, timestamp: u64,
) -> Theme {
    Theme { theme_key, value, caller, timestamp }
}

pub fn theme_from_dashboard(
    theme_key: u32, theme: DashboardTheme, caller: ContractAddress, timestamp: u64,
) -> Theme {
    match theme {
        DashboardTheme::Predefined(value) => theme_with_value(theme_key, value.into(), caller, timestamp),
        DashboardTheme::Custom(custom) => theme_with_value(theme_key, custom.classname, caller, timestamp),
    }
}

impl DashboardThemeDefault of Default<DashboardTheme> {
    fn default() -> DashboardTheme {
        DashboardTheme::Predefined(AvailableTheme::Light)
    }
}

impl ThemeDefault of Default<Theme> {
    fn default() -> Theme {
        theme_with_value(WORLD_THEME_KEY, 'light', default_address(), 0)
    }
}
