defmodule RPS do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: RPS.GameRegistry},
      RPS.GameSupervisor
    ]

    opts = [strategy: :one_for_one, name: Bingo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
