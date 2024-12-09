defmodule FlightTracker.Repo do
  use Ecto.Repo,
    otp_app: :flight_tracker,
    adapter: Ecto.Adapters.Postgres
end
