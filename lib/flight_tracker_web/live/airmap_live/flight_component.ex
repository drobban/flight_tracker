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
      <pre><%= raw(inspect(Aircraft.get_state(@flight_nr).aircraft, pretty: true, limit: 1000)) %></pre>
      <.button
        class="btn btn-primary"
        phx-click={JS.push("lock_flight", value: %{reference: @flight_nr})}
      >
        Lock on flight
      </.button>
    </div>
    """
  end

  @impl true
  def update(%{flight_nr: _flight_nr} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end
end
