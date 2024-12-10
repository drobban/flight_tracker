defmodule FlightTrackerWeb.AircraftLive.Show do
  use FlightTrackerWeb, :live_view

  alias FlightTracker.Skymap

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:aircraft, Skymap.get_aircraft!(id))}
  end

  defp page_title(:show), do: "Show Aircraft"
  defp page_title(:edit), do: "Edit Aircraft"
end
