# FlightTracker

## To start in supervisor.
To start a flight in Supervisor.
one_to_one strategy.

Kill it, and it will start with initial state.

```elixir
Aircraft.supervised_round_trip(FlightControl, FlightTracker.Super)
```

FlightTracker.Super is :global registered.


## Surface to Air missile

Next up for implementation is our surface to air missiles.

This will be kept simple, Spin up a genserver that subscribes on a grid around it to start getting messages from flights passing by just like our client.

When a flight is within range, we shoot it down - by sending a message.
