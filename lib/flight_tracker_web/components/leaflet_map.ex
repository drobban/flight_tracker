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

  # might be off if the maps shape is not close to a square.
  def calculate_initial_map_zoom_level(n, e, s, w) do
    lat_to_radiant = fn lat ->
      sin = :math.sin(lat * :math.pi() / 180)
      radX2 = :math.log((1 + sin) / (1 - sin)) / 2
      max(min(radX2, :math.pi()), -:math.pi()) / 2
    end

    lat_difference = abs(lat_to_radiant.(n) - lat_to_radiant.(s))
    lon_difference = abs(e - w)

    lat_fraction = lat_difference / :math.pi()
    lon_fraction = lon_difference / 360

    # Ensure we never get 0 in division. 1.0e-5 was chosen arbitrarily after trying different values.
    lat_zoom = :math.log(1 / max(lat_fraction, 1.0e-5)) / :math.log(2)
    lon_zoom = :math.log(1 / max(lon_fraction, 1.0e-5)) / :math.log(2)

    # Slight zoom out for vertical dimension, because our map view is very wide and not square.
    min(lat_zoom - 0.5, lon_zoom)
    # Lets not zoom in to infinity
    |> min(20)
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
