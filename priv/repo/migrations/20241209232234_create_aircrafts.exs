defmodule FlightTracker.Repo.Migrations.CreateAircrafts do
  use Ecto.Migration

  def change do
    create table(:aircrafts) do
      add :name, :string
      add :type, :string
      add :pos_lat, :decimal
      add :pos_long, :decimal
      add :destination_lat, :decimal
      add :destination_long, :decimal
      add :status, :string
      add :speed_kmh, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
