defmodule FlightTrackerWeb.AircraftLive.Index do
  use FlightTrackerWeb, :live_view

  alias FlightTracker.Skymap
  alias FlightTracker.Skymap.Aircraft

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :aircrafts, Skymap.list_aircrafts())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Aircraft")
    |> assign(:aircraft, Skymap.get_aircraft!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Aircraft")
    |> assign(:aircraft, %Aircraft{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Aircrafts")
    |> assign(:aircraft, nil)
  end

  @impl true
  def handle_info({FlightTrackerWeb.AircraftLive.FormComponent, {:saved, aircraft}}, socket) do
    {:noreply, stream_insert(socket, :aircrafts, aircraft)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    aircraft = Skymap.get_aircraft!(id)
    {:ok, _} = Skymap.delete_aircraft(aircraft)

    {:noreply, stream_delete(socket, :aircrafts, aircraft)}
  end
end
