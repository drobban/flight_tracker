defmodule FlightTrackerWeb.AirmapLive.Index do
  use FlightTrackerWeb, :live_view
  require Logger
  alias FlightTrackerWeb.Components.LeafletMap, as: LeafletMap

  @impl true
  def mount(_params, _session, socket) do
    opts = [latitude: 51.123456, longitude: 7.123456, reference: "main"]

    socket = LeafletMap.liveview_setup(socket, opts)
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    Logger.debug(inspect assigns)
    ~H"""
      <div class="h-full w-full justify-center items-center">
        <LeafletMap.map class="h-full bg-gray" />
      </div>
    """
  end
end
