defmodule FlightTracker.SkymapTest do
  use FlightTracker.DataCase

  alias FlightTracker.Skymap

  describe "aircrafts" do
    alias FlightTracker.Skymap.Aircraft

    import FlightTracker.SkymapFixtures

    @invalid_attrs %{name: nil, status: nil, type: nil, pos_lat: nil, pos_long: nil, destination_lat: nil, destination_long: nil, speed_kmh: nil}

    test "list_aircrafts/0 returns all aircrafts" do
      aircraft = aircraft_fixture()
      assert Skymap.list_aircrafts() == [aircraft]
    end

    test "get_aircraft!/1 returns the aircraft with given id" do
      aircraft = aircraft_fixture()
      assert Skymap.get_aircraft!(aircraft.id) == aircraft
    end

    test "create_aircraft/1 with valid data creates a aircraft" do
      valid_attrs = %{name: "some name", status: :takeoff, type: :civilian, pos_lat: "120.5", pos_long: "120.5", destination_lat: "120.5", destination_long: "120.5", speed_kmh: 42}

      assert {:ok, %Aircraft{} = aircraft} = Skymap.create_aircraft(valid_attrs)
      assert aircraft.name == "some name"
      assert aircraft.status == :takeoff
      assert aircraft.type == :civilian
      assert aircraft.pos_lat == Decimal.new("120.5")
      assert aircraft.pos_long == Decimal.new("120.5")
      assert aircraft.destination_lat == Decimal.new("120.5")
      assert aircraft.destination_long == Decimal.new("120.5")
      assert aircraft.speed_kmh == 42
    end

    test "create_aircraft/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Skymap.create_aircraft(@invalid_attrs)
    end

    test "update_aircraft/2 with valid data updates the aircraft" do
      aircraft = aircraft_fixture()
      update_attrs = %{name: "some updated name", status: :inflight, type: :military, pos_lat: "456.7", pos_long: "456.7", destination_lat: "456.7", destination_long: "456.7", speed_kmh: 43}

      assert {:ok, %Aircraft{} = aircraft} = Skymap.update_aircraft(aircraft, update_attrs)
      assert aircraft.name == "some updated name"
      assert aircraft.status == :inflight
      assert aircraft.type == :military
      assert aircraft.pos_lat == Decimal.new("456.7")
      assert aircraft.pos_long == Decimal.new("456.7")
      assert aircraft.destination_lat == Decimal.new("456.7")
      assert aircraft.destination_long == Decimal.new("456.7")
      assert aircraft.speed_kmh == 43
    end

    test "update_aircraft/2 with invalid data returns error changeset" do
      aircraft = aircraft_fixture()
      assert {:error, %Ecto.Changeset{}} = Skymap.update_aircraft(aircraft, @invalid_attrs)
      assert aircraft == Skymap.get_aircraft!(aircraft.id)
    end

    test "delete_aircraft/1 deletes the aircraft" do
      aircraft = aircraft_fixture()
      assert {:ok, %Aircraft{}} = Skymap.delete_aircraft(aircraft)
      assert_raise Ecto.NoResultsError, fn -> Skymap.get_aircraft!(aircraft.id) end
    end

    test "change_aircraft/1 returns a aircraft changeset" do
      aircraft = aircraft_fixture()
      assert %Ecto.Changeset{} = Skymap.change_aircraft(aircraft)
    end
  end
end
