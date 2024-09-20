// define the interface
#[dojo::interface]
trait IActions {
    fn increment_global_counter(ref world: IWorldDispatcher);
    fn increment_caller_counter(ref world: IWorldDispatcher);
    fn publish_message(ref world: IWorldDispatcher, message: ByteArray);
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions};
    use starknet::{ContractAddress, get_caller_address};
    use onchain_dash::models::{
        GlobalCounter, CallerCounter, Messages, Message, WORLD_GLOBAL_COUNTER_KEY
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

        fn publish_message(ref world: IWorldDispatcher, message: ByteArray) {
            let caller = get_caller_address();
            let msg = Message { caller, message };
            let mut messages = get!(world, WORLD_GLOBAL_COUNTER_KEY, (Messages));
            messages.messages.append(msg);

            set!(world, (messages));
        }
    //fn spawn(ref world: IWorldDispatcher) {
    //    // Get the address of the current caller, possibly the player's address.
    //    let player = get_caller_address();
    //    // Retrieve the player's current position from the world.
    //    let position = get!(world, player, (Position));
    //    // Update the world state with the new data.
    //    // 1. Set the player's remaining moves to 100.
    //    // 2. Move the player's position 10 units in both the x and y direction.

    //    set!(
    //        world,
    //        (
    //            Moves {
    //                player, remaining: 100, last_direction: Direction::None(()), can_move: true
    //            },
    //            Position {
    //                player, vec: Vec2 { x: position.vec.x + 10, y: position.vec.y + 10 }
    //            },
    //        )
    //    );
    //}

    //// Implementation of the move function for the ContractState struct.
    //fn move(ref world: IWorldDispatcher, direction: Direction) {
    //    // Get the address of the current caller, possibly the player's address.
    //    let player = get_caller_address();

    //    // Retrieve the player's current position and moves data from the world.
    //    let (mut position, mut moves) = get!(world, player, (Position, Moves));

    //    // Deduct one from the player's remaining moves.
    //    moves.remaining -= 1;

    //    // Update the last direction the player moved in.
    //    moves.last_direction = direction;

    //    // Calculate the player's next position based on the provided direction.
    //    let next = next_position(position, direction);

    //    // Update the world state with the new moves data and position.
    //    set!(world, (moves, next));
    //    // Emit an event to the world to notify about the player's move.
    //    emit!(world, (Moved { player, direction }));
    //}
    }
}
