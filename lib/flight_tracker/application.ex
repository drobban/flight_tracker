defmodule FlightTracker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FlightTrackerWeb.Telemetry,
      FlightTracker.Repo,
      {DNSCluster, query: Application.get_env(:flight_tracker, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FlightTracker.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: FlightTracker.Finch},
      # Start a worker by calling: FlightTracker.Worker.start_link(arg)
      # {FlightTracker.Worker, arg},
      {FlightControl.Worker, %{pubsub: Phoenix.PubSub}},
      #{DynamicSupervisor, name: FlightTracker.DynamicSupervisor, strategy: :one_for_one},
      FlightTracker.Super,
      # Start to serve requests, typically the last entry
      FlightTrackerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FlightTracker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FlightTrackerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
