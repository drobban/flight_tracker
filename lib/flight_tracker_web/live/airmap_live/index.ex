defmodule FlightTrackerWeb.AirmapLive.Index do
  use FlightTrackerWeb, :live_view
  alias FlightTrackerWeb.Components.LeafletMap, as: LeafletMap

  @impl true
  def mount(_params, _session, socket) do
    opts = [latitude: 51.123456, longitude: 7.123456, reference: "main"]

    socket = LeafletMap.liveview_setup(socket, opts)
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-screen bg-gray-100">
      <div class="h-screen justify-center items-center rounded-md shadow-lg">
        <LeafletMap.map class="h-80" />
      </div>
    </div>
    """
  end
end
