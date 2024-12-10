defmodule FlightTracker.Skymap.Aircraft do
  use Ecto.Schema
  import Ecto.Changeset

  schema "aircrafts" do
    field :name, :string
    field :status, Ecto.Enum, values: [:takeoff, :inflight, :landed]
    field :type, Ecto.Enum, values: [:civilian, :military, :transport]
    field :pos_lat, :decimal
    field :pos_long, :decimal
    field :destination_lat, :decimal
    field :destination_long, :decimal
    field :speed_kmh, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(aircraft, attrs) do
    aircraft
    |> cast(attrs, [
      :name,
      :type,
      :pos_lat,
      :pos_long,
      :destination_lat,
      :destination_long,
      :status,
      :speed_kmh
    ])
    |> validate_required([
      :name,
      :type,
      :pos_lat,
      :pos_long,
      :destination_lat,
      :destination_long,
      :status,
      :speed_kmh
    ])
  end
end
