defmodule Rps.GameServer do
  @moduledoc """
  A game server process that holds a `Game` struct and players as its state.
  """

  use GenServer

  require Logger

  # Client (Public) Interface

  @doc """
  Spawns a new game server process registered under the given `game_name` and started by `user`.
  """
  def start_link(game_name, user) do
    GenServer.start_link(__MODULE__, {game_name, user}, name: via_tuple(game_name))
  end

  @doc """
  Removes a tuple used to register and lookup a game server process by name.
  """
  def via_tuple(game_name) do
    {:via, Registry, {Rps.GameRegistry, game_name}}
  end

  @doc """
  Removes `true` if the game server process registered under the
  given `game_name`, or `false` if no process is registered.
  """
  def alive?(game_name) do
    game_name
    |> via_tuple()
    |> GenServer.whereis()
    |> case do
      pid when is_pid(pid) ->
        Process.alive?(pid)

      nil ->
        false
    end
  end

  @doc """
  Removes the info of the game registered under the given `game_name`.
  """
  def info(game_name) do
    GenServer.call(via_tuple(game_name), :info)
  end

  def join(game_name, player) do
    GenServer.call(via_tuple(game_name), {:join, player})
  end

  def move(game_name, player, choice) do
    GenServer.call(via_tuple(game_name), {:move, player, choice})
  end

  # Server Callbacks

  def init({game_name, user}) do
    Logger.info("Spawned game server process named '#{game_name}'.")
    {:ok, %{game: Rps.Game.new(), first_player: user, second_player: nil, move: :first}}
  end

  def handle_call(:info, _from, state) do
    {:reply, get_info(state), state}
  end

  def handle_call({:join, player}, _from, %{first_player: player} = state),
    do: {:reply, {:ok, :first}, state}
  def handle_call({:join, player}, _from, %{second_player: player} = state),
    do: {:reply, {:ok, :second}, state}
  def handle_call({:join, player}, _from, %{second_player: nil} = state),
    do: {:reply, {:ok, :second}, %{state | second_player: player}}
  def handle_call({:join, _player}, _from, state),
    do: {:reply, {:error, :another_player_already_joined}, state}

  def handle_call({:move, player, choice}, _from, %{game: game, first_player: player} = state) do
    new_state = %{state | game: Rps.Game.first_player_choice(game, choice)}
    {:reply, get_info(new_state), new_state}
  end

  def handle_call({:move, player, choice}, _from, %{game: game, second_player: player} = state) do
    new_state = %{state | game: Rps.Game.second_player_choice(game, choice)}
    {:reply, get_info(new_state), new_state}
  end

  defp get_info(%{game: game, first_player: first_player, second_player: second_player}) do
    %{
      current_round: game.current_round,
      rounds: game.rounds,
      first_player: player_info(first_player, game.first_player_score),
      second_player: player_info(second_player, game.second_player_score),
      result: game.result
    }
  end

  defp player_info(nil, _score), do: nil
  defp player_info(player, score), do: %{id: player.id, name: player.name, score: score}
end
