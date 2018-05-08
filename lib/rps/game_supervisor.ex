defmodule RPS.GameSupervisor do
  @moduledoc """
  A supervisor that starts `GameServer` processes dynamically.
  """

  use DynamicSupervisor

  alias RPS.GameServer

  @doc false
  def start_link(_arg), do: DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  @doc false
  def init(_args), do: DynamicSupervisor.init(strategy: :one_for_one)

  @doc """
  Starts a `GameServer` process and supervises it.
  """
  def start_game(game_name) do
    child_spec = %{
      id: GameServer,
      start: {GameServer, :start_link, [game_name]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end
end
