defmodule FlightTrackerWeb.AirmapLive.FlightComponent do
  use FlightTrackerWeb, :live_component

  alias Aircraft

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Flight <%= @flight_nr %></:subtitle>
      </.header>
      <pre><%= raw(inspect(@flight_state, pretty: true, limit: 1000)) %></pre>
      <.button
        class="btn btn-primary"
        phx-click={JS.push("lock_flight", value: %{reference: @flight_nr})}
      >
        Lock on flight
      </.button>
      <.button
        class="btn btn-secondary"
        phx-click={JS.push("unlock_flight", value: %{reference: @flight_nr})}
      >
        Unlock from flight
      </.button>

    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(:flight_state, %{})}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:flight_state, Aircraft.get_state(assigns.flight_nr).aircraft)

    start_timer(socket.assigns.myself, assigns.flight_nr)
    {:ok, socket}
  end

  # Public function to start the timer
  def start_timer(component_id, flight_nr) do
    parent_pid = self()

    Task.start(fn ->
      Process.sleep(10_000)

      send_update(parent_pid, component_id, %{flight_nr: flight_nr})
    end)
  end
end
