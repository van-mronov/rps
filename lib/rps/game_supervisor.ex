defmodule Rps.GameSupervisor do
  @moduledoc """
  A supervisor that starts `GameServer` processes dynamically.
  """

  use DynamicSupervisor

  alias Rps.GameServer

  @doc false
  def start_link(_arg), do: DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  @doc false
  def init(_args), do: DynamicSupervisor.init(strategy: :one_for_one)

  @doc """
  Starts a `GameServer` process and supervises it.
  """
  def start_game(game_name, user) do
    child_spec = %{
      id: GameServer,
      start: {GameServer, :start_link, [game_name, user]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def current_games do
    __MODULE__
    |> Supervisor.which_children()
    |> Enum.map(fn {_id, pid, _type, _modules} -> GenServer.call(pid, :info) end)
  end
end
