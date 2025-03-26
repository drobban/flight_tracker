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
      |> assign(:show_modal, false)
      |> assign(:flight_nr, nil)

    {:ok, socket}
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

    lat_lng = "#{lat1 + lat_buff}:#{lng1 - lng_buff}_#{lat2 - lat_buff}:#{lng2 + lng_buff}"
    PubSub.subscribe(FlightTracker.PubSub, lat_lng)
    FlightControl.subscribe(lat_lng)

    {:noreply, socket |> assign(map_bounds: bounds) |> assign(:substring, lat_lng)}
  end

  def handle_event("show_details", %{"flight_nr" => reference}, socket) do
    {:noreply, socket |> assign(:show_modal, true) |> assign(:flight_nr, reference)}
  end

  @impl true
  def handle_event("hide_details", _, socket) do
    {:noreply, socket |> assign(:show_modal, false) |> assign(:flight_nr, nil)}
  end

  @impl true
  def handle_event("lock_flight", %{"reference" => name}, socket) do
    Logger.debug("Flight lock requested")

    socket =
      socket
      |> Phoenix.LiveView.push_event("set_ref_trace", %{reference: name})

    {:noreply, socket}
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
  def handle_info(%SamSite.State{status: :online} = samsite, socket) do
     socket =
      socket
      |> Phoenix.LiveView.push_event("add_marker", %{
        reference: samsite.name,
        lat: samsite.pos_lat,
        lon: samsite.pos_lng,
        bearing: 180.0,
        icon: "aa"
      })

    {:noreply, socket}
  end

  @impl true
  def handle_info(%Aircraft.State{status: :inflight} = aircraft, socket) do
    socket =
      socket
      |> Phoenix.LiveView.push_event("add_marker", %{
        reference: aircraft.name,
        lat: aircraft.pos_lat,
        lon: aircraft.pos_lng,
        bearing: aircraft.bearing,
        icon: "civilian-transport"
      })

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-full w-full justify-center items-center">
      <LeafletMap.map class="h-full bg-gray" />
    </div>
    <.panel_modal
      :if={@show_modal}
      id="aircraft-modal"
      show
      on_cancel={JS.push("hide_details", value: %{})}
    >
      <div class="min-h-full" style="min-height: 80vh">
        <.live_component
          module={FlightTrackerWeb.AirmapLive.FlightComponent}
          id={"comp-#{@flight_nr}"}
          title="Details"
          flight_nr={@flight_nr}
        />
      </div>
    </.panel_modal>
    """
  end

  defp calc_bound_buffer(lat1, lng1, lat2, lng2) do
    lat_buffer = (lat1 - lat2) / 2
    lng_buffer = (lng2 - lng1) / 2

    {lat_buffer, lng_buffer}
  end
end
