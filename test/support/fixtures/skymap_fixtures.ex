defmodule FlightTracker.SkymapFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FlightTracker.Skymap` context.
  """

  @doc """
  Generate a aircraft.
  """
  def aircraft_fixture(attrs \\ %{}) do
    {:ok, aircraft} =
      attrs
      |> Enum.into(%{
        destination_lat: "120.5",
        destination_long: "120.5",
        name: "some name",
        pos_lat: "120.5",
        pos_long: "120.5",
        speed_kmh: 42,
        status: :takeoff,
        type: :civilian
      })
      |> FlightTracker.Skymap.create_aircraft()

    aircraft
  end
end
