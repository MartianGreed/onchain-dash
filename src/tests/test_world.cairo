#[cfg(test)]
#[feature("deprecated-starknet-consts")]
mod tests {
    use core::traits::TryInto;
    use dojo_cairo_test::WorldStorageTestTrait;
    use dojo::model::{ModelStorage, ModelStorageTest};
    use dojo::world::{WorldStorageTrait, WorldStorage};
    use dojo::world::world;
    use dojo_cairo_test::{
        spawn_test_world, NamespaceDef, TestResource, ContractDefTrait, ContractDef
    };

    use onchain_dash::{
        systems::{actions::{actions, IActionsDispatcher, IActionsDispatcherTrait}},
        models::{
            {
                GlobalCounter, m_GlobalCounter, CallerCounter, m_CallerCounter,
                WORLD_GLOBAL_COUNTER_KEY, Theme, m_Theme, WORLD_THEME_KEY, DashboardTheme, AvailableTheme,
                theme_with_value
            }
        },
    };

    use starknet::{testing, contract_address_const};

    fn ndef() -> NamespaceDef {
        NamespaceDef {
            namespace: "onchain_dash", resources: [
                TestResource::Model(m_GlobalCounter::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Model(m_CallerCounter::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Model(m_Theme::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Contract(actions::TEST_CLASS_HASH),
            ].span(),
        }
    }
    fn contract_defs() -> Span<ContractDef> {
        [
            ContractDefTrait::new(@"onchain_dash", @"actions")
                .with_writer_of([dojo::utils::bytearray_hash(@"onchain_dash")].span())
        ].span()
    }

    fn setup_world() -> (WorldStorage, IActionsDispatcher) {
        let ndef = ndef();
        let mut world = spawn_test_world(world::TEST_CLASS_HASH.try_into().unwrap(), [ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"actions").unwrap();
        let actions_system = IActionsDispatcher { contract_address };

        (world, actions_system)
    }


    #[test]
    fn test_world_counter() {
        let (world, actions_system) = setup_world();

        let counter: GlobalCounter = world.read_model(WORLD_GLOBAL_COUNTER_KEY);
        assert(counter.counter == 0, 'world initial count invalid');
        actions_system.increment_global_counter();

        let counter: GlobalCounter = world.read_model(WORLD_GLOBAL_COUNTER_KEY);
        assert(counter.counter == 1, 'global increment is not working');
        actions_system.increment_global_counter();

        let counter: GlobalCounter = world.read_model(WORLD_GLOBAL_COUNTER_KEY);
        assert(counter.counter == 2, 'global increment is not working');
    }

    #[test]
    fn test_caller_counter() {
        // caller
        let caller_1 = contract_address_const::<0x0>();

        let (world, actions_system) = setup_world();

        let counter: CallerCounter = world.read_model(caller_1);
        assert(counter.counter == 0, 'caller_1 init count invalid');

        testing::set_caller_address(caller_1);
        actions_system.increment_caller_counter();

        let counter: CallerCounter = world.read_model(caller_1);
        assert(counter.counter == 1, 'caller_1 incr is not working');

        let caller_2 = contract_address_const::<0x1>();

        let counter_2: CallerCounter = world.read_model(caller_2);
        assert(counter_2.counter == 0, 'caller_2 init count invalid');

        testing::set_caller_address(caller_2);
        actions_system.increment_caller_counter();

        let counter_2: CallerCounter = world.read_model(caller_1);
        assert(counter_2.counter == 2, 'caller_2 incr is not working');

        let counter_1: CallerCounter = world.read_model(caller_1);
        assert(counter_1.counter != 1, 'caller_1 has changed value');
    }

    #[test]
    fn test_theme() {
        let (mut world, actions_system) = setup_world();

        world.write_model_test(
            @theme_with_value(
                WORLD_THEME_KEY,
                'light',
                contract_address_const::<0x0>(),
                0,
            ),
        );

        testing::set_caller_address(contract_address_const::<0x0>());
        actions_system.change_theme(DashboardTheme::Predefined(AvailableTheme::Light));
        let theme: Theme = world.read_model(WORLD_THEME_KEY);
        assert(
            theme.value == 'light',
            'theme initial value invalid'
        );
        actions_system.change_theme(DashboardTheme::Predefined(AvailableTheme::Dark));
        let theme: Theme = world.read_model(WORLD_THEME_KEY);
        assert(
            theme.value == 'dark',
            'theme change is not working'
        );
    }
}
