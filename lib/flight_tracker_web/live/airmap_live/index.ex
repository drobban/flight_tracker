defmodule FlightTrackerWeb.AirmapLive.Index do
  use FlightTrackerWeb, :live_view
  require Logger
  alias FlightTrackerWeb.Components.LeafletMap, as: LeafletMap
  alias Phoenix
  alias Phoenix.PubSub
  alias FlightControl

  @impl true
  def mount(_params, _session, socket) do
    # Setup PubSub 
    # the topic name is a list of two lat_lngs creating a box.
    # lat_lng1 represents upper left corner of the box.
    # lat_lng2 represents lower right corner of the box.
    lat_lng =  "51.123456:7.123456_45.123456:5.123456"
    PubSub.subscribe(FlightTracker.PubSub, lat_lng)
    FlightControl.subscribe(lat_lng)
    opts = [latitude: 51.123456, longitude: 7.123456, reference: "main"]

    socket = LeafletMap.liveview_setup(socket, opts)
    {:ok, socket}
  end

  @doc """
  This handle_event is just a simple test.
  """
  @impl true
  def handle_event("add-plane", _unsigned_params, socket) do
    socket =
      socket
      |> Phoenix.LiveView.push_event("add_marker", %{reference: "MH417", lat: 51.123, lon: 7.3})

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    Logger.debug(inspect(assigns))

    ~H"""
    <div class="h-full w-full justify-center items-center">
      <LeafletMap.map class="h-full bg-gray" />
    </div>
    <.button phx-click="add-plane">En till</.button>
    """
  end
end
