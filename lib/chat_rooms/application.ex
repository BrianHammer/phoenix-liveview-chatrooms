defmodule ChatRooms.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ChatRoomsWeb.Telemetry,
      ChatRooms.Repo,
      {DNSCluster, query: Application.get_env(:chat_rooms, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ChatRooms.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ChatRooms.Finch},
      # Start a worker by calling: ChatRooms.Worker.start_link(arg)
      # {ChatRooms.Worker, arg},
      # Start to serve requests, typically the last entry
      ChatRoomsWeb.Endpoint,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChatRooms.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChatRoomsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
