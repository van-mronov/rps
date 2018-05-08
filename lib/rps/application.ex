defmodule RPS.Application do
  use Application

  def start(_type, _args) do
    children = [
      RPS.Repo,
      RPSWeb.Endpoint,
      {Registry, keys: :unique, name: RPS.GameRegistry},
      RPS.GameSupervisor
    ]

    opts = [strategy: :one_for_one, name: RPS.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    RPSWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
