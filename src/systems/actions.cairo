use onchain_dash::models::AvailableTheme;

// define the interface
#[dojo::interface]
trait IActions {
    fn increment_global_counter(ref world: IWorldDispatcher);
    fn increment_caller_counter(ref world: IWorldDispatcher);
    fn change_theme(ref world: IWorldDispatcher, value: u8);
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions};
    use starknet::{ContractAddress, get_caller_address};
    use onchain_dash::models::{
        GlobalCounter, CallerCounter, WORLD_GLOBAL_COUNTER_KEY, Theme, WORLD_THEME_KEY, AvailableTheme
    };


    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn increment_global_counter(ref world: IWorldDispatcher) {
            let mut counter = get!(world, WORLD_GLOBAL_COUNTER_KEY, (GlobalCounter));
            counter.counter += 1;

            set!(world, (counter));
        }

        fn increment_caller_counter(ref world: IWorldDispatcher) {
            let caller = get_caller_address();
            let mut counter = get!(world, caller, (CallerCounter));
            counter.counter += 1;

            set!(world, (counter));
        }

        fn change_theme(ref world: IWorldDispatcher, value: u8) {
            let caller = get_caller_address();
            let mut theme = get!(world, WORLD_THEME_KEY, (Theme));
            theme.value = value.into();
            theme.caller = caller;
            theme.timestamp = starknet::get_block_timestamp();

            set!(world, (theme));
        }
    }
}
