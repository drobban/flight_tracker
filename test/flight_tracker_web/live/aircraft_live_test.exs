defmodule FlightTrackerWeb.AircraftLiveTest do
  use FlightTrackerWeb.ConnCase

  import Phoenix.LiveViewTest
  import FlightTracker.SkymapFixtures

  @create_attrs %{name: "some name", status: :takeoff, type: :civilian, pos_lat: "120.5", pos_long: "120.5", destination_lat: "120.5", destination_long: "120.5", speed_kmh: 42}
  @update_attrs %{name: "some updated name", status: :inflight, type: :military, pos_lat: "456.7", pos_long: "456.7", destination_lat: "456.7", destination_long: "456.7", speed_kmh: 43}
  @invalid_attrs %{name: nil, status: nil, type: nil, pos_lat: nil, pos_long: nil, destination_lat: nil, destination_long: nil, speed_kmh: nil}

  defp create_aircraft(_) do
    aircraft = aircraft_fixture()
    %{aircraft: aircraft}
  end

  describe "Index" do
    setup [:create_aircraft]

    test "lists all aircrafts", %{conn: conn, aircraft: aircraft} do
      {:ok, _index_live, html} = live(conn, ~p"/aircrafts")

      assert html =~ "Listing Aircrafts"
      assert html =~ aircraft.name
    end

    test "saves new aircraft", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/aircrafts")

      assert index_live |> element("a", "New Aircraft") |> render_click() =~
               "New Aircraft"

      assert_patch(index_live, ~p"/aircrafts/new")

      assert index_live
             |> form("#aircraft-form", aircraft: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#aircraft-form", aircraft: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/aircrafts")

      html = render(index_live)
      assert html =~ "Aircraft created successfully"
      assert html =~ "some name"
    end

    test "updates aircraft in listing", %{conn: conn, aircraft: aircraft} do
      {:ok, index_live, _html} = live(conn, ~p"/aircrafts")

      assert index_live |> element("#aircrafts-#{aircraft.id} a", "Edit") |> render_click() =~
               "Edit Aircraft"

      assert_patch(index_live, ~p"/aircrafts/#{aircraft}/edit")

      assert index_live
             |> form("#aircraft-form", aircraft: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#aircraft-form", aircraft: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/aircrafts")

      html = render(index_live)
      assert html =~ "Aircraft updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes aircraft in listing", %{conn: conn, aircraft: aircraft} do
      {:ok, index_live, _html} = live(conn, ~p"/aircrafts")

      assert index_live |> element("#aircrafts-#{aircraft.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#aircrafts-#{aircraft.id}")
    end
  end

  describe "Show" do
    setup [:create_aircraft]

    test "displays aircraft", %{conn: conn, aircraft: aircraft} do
      {:ok, _show_live, html} = live(conn, ~p"/aircrafts/#{aircraft}")

      assert html =~ "Show Aircraft"
      assert html =~ aircraft.name
    end

    test "updates aircraft within modal", %{conn: conn, aircraft: aircraft} do
      {:ok, show_live, _html} = live(conn, ~p"/aircrafts/#{aircraft}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Aircraft"

      assert_patch(show_live, ~p"/aircrafts/#{aircraft}/show/edit")

      assert show_live
             |> form("#aircraft-form", aircraft: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#aircraft-form", aircraft: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/aircrafts/#{aircraft}")

      html = render(show_live)
      assert html =~ "Aircraft updated successfully"
      assert html =~ "some updated name"
    end
  end
end
