#[cfg(test)]
mod tests {
    // import world dispatcher
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    // import test utils
    use dojo::utils::test::{spawn_test_world, deploy_contract};
    // import test utils
    use onchain_dash::{
        systems::{actions::{actions, IActionsDispatcher, IActionsDispatcherTrait}},
        models::{{GlobalCounter, CallerCounter, WORLD_GLOBAL_COUNTER_KEY}},
    };
    use onchain_dash::models::{global_counter, caller_counter};
    use starknet::{testing, contract_address_const};

    fn setup_world() -> (IWorldDispatcher, IActionsDispatcher) {
        let mut models = array![
            global_counter::TEST_CLASS_HASH,
            caller_counter::TEST_CLASS_HASH,
        ];
        // models

        // deploy world with models
        let world = spawn_test_world(["onchain_dash"].span(), models.span());

        // deploy systems contract
        let contract_address = world
            .deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap());
        let actions_system = IActionsDispatcher { contract_address };

        world.grant_writer(dojo::utils::bytearray_hash(@"onchain_dash"), contract_address);
        (world, actions_system)
    }


    #[test]
    fn test_world_counter() {
        let (world, actions_system) = setup_world();

        let counter = get!(world, WORLD_GLOBAL_COUNTER_KEY, (GlobalCounter));
        assert(counter.counter == 0, 'world initial count invalid');
        actions_system.increment_global_counter();
        let counter = get!(world, WORLD_GLOBAL_COUNTER_KEY, (GlobalCounter));
        assert(counter.counter == 1, 'global increment is not working');
        actions_system.increment_global_counter();
        let counter = get!(world, WORLD_GLOBAL_COUNTER_KEY, (GlobalCounter));
        assert(counter.counter == 2, 'global increment is not working');
    }

    #[test]
    fn test_caller_counter() {
        // caller
        let caller_1 = contract_address_const::<0x0>();

        let (world, actions_system) = setup_world();

        let counter = get!(world, caller_1, (CallerCounter));
        assert(counter.counter == 0, 'caller_1 init count invalid');

        testing::set_caller_address(caller_1);
        actions_system.increment_caller_counter();

        let counter = get!(world, caller_1, (CallerCounter));
        assert(counter.counter == 1, 'caller_1 incr is not working');

        let caller_2 = contract_address_const::<0x1>();

        let counter_2 = get!(world, caller_2, (CallerCounter));
        assert(counter_2.counter == 0, 'caller_2 init count invalid');

        testing::set_caller_address(caller_2);
        actions_system.increment_caller_counter();

        let counter_2 = get!(world, caller_1, (CallerCounter));
        assert(counter_2.counter == 2, 'caller_2 incr is not working');

        let counter_1 = get!(world, caller_1, (CallerCounter));
        assert(counter_1.counter != 1, 'caller_1 has changed value');
    }
}
