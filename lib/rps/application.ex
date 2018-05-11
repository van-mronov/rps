defmodule Rps.Application do
  use Application

  def start(_type, _args) do
    children = [
      Rps.Repo,
      RpsWeb.Endpoint,
      {Registry, keys: :unique, name: Rps.GameRegistry},
      Rps.GameSupervisor
    ]

    Rps.Leaderboard.new()

    opts = [strategy: :one_for_one, name: Rps.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    RpsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
