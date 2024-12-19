defmodule FlightTrackerWeb.AirmapLive.Index do
  use FlightTrackerWeb, :live_view
  require Logger
  alias FlightTrackerWeb.Components.LeafletMap, as: LeafletMap
  alias Phoenix
  alias Phoenix.PubSub
  alias FlightControl
  alias Aircraft

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
      |> Phoenix.LiveView.push_event("add_marker", %{reference: "MH418", lat: 51.123, lon: 7.3})

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

    {lat_buff, lng_buff} = calc_bound_buffer(lat1, lng1, lat2, lng2)

    lat_lng = "#{lat1+lat_buff}:#{lng1-lng_buff}_#{lat2-lat_buff}:#{lng2+lng_buff}"
    PubSub.subscribe(FlightTracker.PubSub, lat_lng)
    FlightControl.subscribe(lat_lng)

    {:noreply, socket |> assign(map_bounds: bounds) |> assign(:substring, lat_lng)}
  end

  @impl true
  def handle_info(%Aircraft.State{status: :landed} = aircraft, socket) do
    # Add marker will add new and update old markers.
    socket =
      socket
      |> Phoenix.LiveView.push_event("remove_marker", %{reference: aircraft.name})

    {:noreply, socket}
  end

  @impl true
  def handle_info(%Aircraft.State{status: :inflight} = aircraft, socket) do
    socket =
      socket
      |> Phoenix.LiveView.push_event("add_marker", %{
        reference: aircraft.name,
        lat: aircraft.pos_lat,
        lon: aircraft.pos_long
      })

    {:noreply, socket}
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

  defp calc_bound_buffer(lat1, lng1, lat2, lng2) do
      lat_buffer = (lat1-lat2)/2 
      lng_buffer = (lng2-lng1)/2 

      {lat_buffer, lng_buffer}
  end
end
