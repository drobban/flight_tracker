defmodule FlightTracker.Super do
  use DynamicSupervisor

  def start_link(_) do
    {:ok, pid} = DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)

    :global.register_name(__MODULE__, pid)

    {:ok, pid}
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 30, max_seconds: 10)
  end
end
