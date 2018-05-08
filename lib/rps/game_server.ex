defmodule RPS.GameServer do
  @moduledoc """
  A game server process that holds a `Game` struct as its state.
  """

  use GenServer

  require Logger

  # Client (Public) Interface

  @doc """
  Spawns a new game server process registered under the given `game_name`.
  """
  def start_link(game_name) do
    GenServer.start_link(__MODULE__, game_name, name: via_tuple(game_name))
  end

  @doc """
  Returns a tuple used to register and lookup a game server process by name.
  """
  def via_tuple(game_name) do
    {:via, Registry, {RPS.GameRegistry, game_name}}
  end

  # Server Callbacks

  def init(game_name) do
    Logger.info("Spawned game server process named '#{game_name}'.")
    {:ok, RPS.Game.new()}
  end
end
