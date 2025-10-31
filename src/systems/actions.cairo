use onchain_dash::models::DashboardTheme;

// define the interface
#[starknet::interface]
pub trait IActions<T> {
    fn increment_global_counter(ref self: T);
    fn increment_caller_counter(ref self: T);
    fn change_theme(ref self: T, value: DashboardTheme);
}

// dojo decorator
#[dojo::contract]
pub mod actions {
    use super::{IActions};
    use dojo::model::ModelStorage;
    use onchain_dash::models::{
        GlobalCounter, CallerCounter, WORLD_GLOBAL_COUNTER_KEY, WORLD_THEME_KEY,
        DashboardTheme, theme_from_dashboard
    };
    use starknet::{get_caller_address, get_block_timestamp};

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn increment_global_counter(ref self: ContractState) {
            let mut world = self.world(@"onchain_dash");
            let mut counter: GlobalCounter = world.read_model(WORLD_GLOBAL_COUNTER_KEY);
            counter.counter += 1;

            world.write_model(@counter);
        }

        fn increment_caller_counter(ref self: ContractState) {
            let mut world = self.world(@"onchain_dash");
            let caller = get_caller_address();
            let mut counter: CallerCounter = world.read_model(caller);
            counter.counter += 1;
            counter.timestamp = Option::Some(get_block_timestamp());

            world.write_model(@counter);
        }

        fn change_theme(ref self: ContractState, value: DashboardTheme) {
            let mut world = self.world(@"onchain_dash");
            let caller = get_caller_address();
            let timestamp = starknet::get_block_timestamp();
            let theme = theme_from_dashboard(WORLD_THEME_KEY, value, caller, timestamp);

            world.write_model(@theme);
        }
    }
}
