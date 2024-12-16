defmodule FlightTrackerWeb.Components.LeafletMap do
  use Phoenix.Component

  attr :class, :string, default: nil

  def map(assigns) do
    ~H"""
    <div class="h-full" style="overflow: hidden" phx-update="ignore" id="mapcontainer">
      <div class={@class} phx-hook="Map" id="mapid" style="height: 80vh;"></div>
    </div>
    """
  end

  def liveview_setup(socket, opts \\ []) do
    socket
    |> Phoenix.LiveView.push_event("view_init", %{
      reference: opts[:reference],
      lat: opts[:latitude],
      lon: opts[:longitude],
      zoom_level: opts[:zoom_level] || 15
    })
    |> Phoenix.LiveView.push_event("add_marker", %{
      reference: opts[:reference],
      lat: opts[:latitude],
      lon: opts[:longitude]
    })

    # |> Phoenix.LiveView.push_event("update_marker_position", %{
    #   reference: opts[:reference],
    #   lat: address[:latitude],
    #   lon: address[:longitude],
    #   center_view: true
    # })
  end
end
