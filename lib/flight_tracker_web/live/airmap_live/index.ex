defmodule FlightTrackerWeb.AirmapLive.Index do
  use FlightTrackerWeb, :live_view
  require Logger
  alias FlightTrackerWeb.Components.LeafletMap, as: LeafletMap
  alias Phoenix
  alias Phoenix.PubSub
  alias FlightControl

  @impl true
  def mount(_params, _session, socket) do
    opts = [latitude: 51.123456, longitude: 7.123456, reference: "main"]

    socket =
      socket
      |> LeafletMap.liveview_setup(opts)
      |> assign(:map_bounds, nil)
      |> assign(:substring, nil)

    {:ok, socket}
  end

  @doc """
  add-plane is just a simple test.

  update_bounds recieves new view bounds of the leaflet js map on 
  init/mount and every map update (zoom/movement)

  """
  @impl true
  def handle_event("add-plane", _unsigned_params, socket) do
    socket =
      socket
      |> Phoenix.LiveView.push_event("add_marker", %{reference: "MH417", lat: 51.123, lon: 7.3})

    {:noreply, socket}
  end

  def handle_event(
        "update_bounds",
        %{
          "bounds" =>
            %{
              "north_west" => %{"lat" => lat1, "lng" => lng1},
              "south_east" => %{"lat" => lat2, "lng" => lng2}
            } = bounds
        },
        socket
      ) do
    if !is_nil(socket.assigns.substring) do
      PubSub.unsubscribe(FlightTracker.PubSub, socket.assigns.substring)
      FlightControl.unsubscribe(socket.assigns.substring)
    end

    # This is what our aircraft will construct and check if inside of. 
    Logger.debug(inspect(FlightControl.Grid.Square.new(lat1, lng1, lat2, lng2)))

    lat_lng = "#{lat1}:#{lng1}_#{lat2}:#{lng2}"
    PubSub.subscribe(FlightTracker.PubSub, lat_lng)
    FlightControl.subscribe(lat_lng)

    {:noreply, socket |> assign(map_bounds: bounds) |> assign(:substring, lat_lng)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-full w-full justify-center items-center">
      <LeafletMap.map class="h-full bg-gray" />
    </div>
    <.button phx-click="add-plane">En till</.button>
    """
  end
end
