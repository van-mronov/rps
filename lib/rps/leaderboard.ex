defmodule Rps.Leaderboard do
  @moduledoc """
  Module provides interface to the leaderboard.
  """

  alias Rps.Accounts.User

  @type raw_item ::
          {id :: integer, name :: String.t(), game_played :: integer, won :: integer(),
           lost :: integer(), draw :: integer()}

  @type item :: %{
          id: integer(),
          name: String.t(),
          game_played: integer(),
          won: integer(),
          lost: integer(),
          draw: integer()
        }

  @game_played_pos 3
  @wins_pos 4
  @lost_pos 5
  @draw_pos 6

  @win_inc [{@game_played_pos, 1}, {@wins_pos, 1}]
  @lost_inc [{@game_played_pos, 1}, {@lost_pos, 1}]
  @draw_inc [{@game_played_pos, 1}, {@draw_pos, 1}]

  @doc """
  Creates the leaderboard table.
  """
  def new, do: :ets.new(:user_results, [:set, :public, :named_table])

  @doc """
  Inserts the new user into the leaderboard with blank results.
  """
  @spec new_user(User.t()) :: true
  def new_user(user), do: :ets.insert(:user_results, {user.id, user.name, 0, 0, 0, 0})

  @doc """
  Returns the user results.
  """
  @spec user_results(User.t()) :: item | nil
  def user_results(user) do
    :user_results
    |> :ets.lookup(user.id)
    |> case do
      [user_result] ->
        into_map(user_result)

      [] ->
        nil
    end
  end

  @doc """
  Updates the user results with the game finished witn win.
  """
  @spec win_game(User.t(), User.t()) :: :ok
  def win_game(winner, loser) do
    :ets.update_counter(:user_results, winner.id, @win_inc)
    :ets.update_counter(:user_results, loser.id, @lost_inc)
    :ok
  end

  @doc """
  Updates the user results with the draw game.
  """
  @spec draw_game(User.t(), User.t()) :: :ok
  def draw_game(first_user, second_user) do
    :ets.update_counter(:user_results, first_user.id, @draw_inc)
    :ets.update_counter(:user_results, second_user.id, @draw_inc)
    :ok
  end

  @doc """
  Returns the leaderboard as a table sorted by numbers of wins/number of played games.
  """
  @spec table :: list(item)
  def table do
    :user_results
    |> :ets.tab2list()
    |> Enum.map(&into_map/1)
    |> Enum.sort(
      &(Map.fetch!(&1, :won) > Map.fetch!(&2, :won) ||
          (Map.fetch!(&1, :won) == Map.fetch!(&2, :won) &&
             Map.fetch!(&1, :game_played) > Map.fetch!(&2, :game_played)))
    )
  end

  @doc """
  Deletes all entries from leaderboard.
  """
  @spec clear :: true
  def clear, do: :ets.delete_all_objects(:user_results)

  @spec into_map(raw_item) :: item
  def into_map({id, name, game_played, won, lost, draw}) do
    %{id: id, name: name, game_played: game_played, won: won, lost: lost, draw: draw}
  end
end
