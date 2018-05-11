defmodule Rps.Game do
  @moduledoc """
  Module implements a basic logic of the 10-rounds Rock-Paper-Scissors game.
  """

  alias Rps.{Game, Round}

  defstruct current_round: %Round{},
            duration: Application.get_env(:rps, :game_duration, 10),
            rounds: [],
            first_player_score: 0,
            second_player_score: 0,
            result: nil

  @doc """
  Creates a new game.

  ## Examples

      iex> Rps.Game.new()
      #Game<current_round: #Round<first_player_choice: nil, second_player_choice: nil, result: nil>, first_player_score: 0, second_player_score: 0, result: nil>

  """
  def new, do: %Game{}

  @doc """
  Updates the first player's choice for the current round.

  ## Examples

      iex> game = Rps.Game.new()
      iex> Rps.Game.first_player_choice(game, :rock)
      #Game<current_round: #Round<first_player_choice: :rock, second_player_choice: nil, result: nil>, first_player_score: 0, second_player_score: 0, result: nil>

  """
  def first_player_choice(game, choice), do: update_round_with_player_choice(game, :first, choice)

  @doc """
  Updates the second player's choice and finishes the current round. Finishes the game if it was the last round.

  ## Examples

      iex> Rps.Game.new()
      ...> |> Rps.Game.first_player_choice(:rock)
      ...> |> Rps.Game.second_player_choice(:scissors)
      #Game<current_round: #Round<first_player_choice: nil, second_player_choice: nil, result: nil>, first_player_score: 1, second_player_score: 0, result: nil>

  """
  def second_player_choice(game, choice) do
    game
    |> update_round_with_player_choice(:second, choice)
    |> update_round_result()
    |> update_scores()
    |> finish_round()
    |> maybe_update_result()
  end

  @doc false
  def to_doc(%Game{
        current_round: round,
        first_player_score: fps,
        second_player_score: sps,
        result: result
      }) do
    "current_round: #{inspect(round)}, first_player_score: #{inspect(fps)}, second_player_score: #{
      inspect(sps)
    }, result: #{inspect(result)}"
  end

  defp update_round_with_player_choice(
         %Game{current_round: round} = game,
         player_position,
         choice
       ) do
    %{game | current_round: Round.player_choice(round, player_position, choice)}
  end

  defp update_round_result(%Game{current_round: round} = game) do
    %{game | current_round: Round.update_result(round)}
  end

  defp update_scores(
         %Game{current_round: %Round{result: :first}, first_player_score: score} = game
       ) do
    %{game | first_player_score: score + 1}
  end

  defp update_scores(
         %Game{current_round: %Round{result: :second}, second_player_score: score} = game
       ) do
    %{game | second_player_score: score + 1}
  end

  defp update_scores(game) do
    game
  end

  defp finish_round(%Game{current_round: round, rounds: rounds, duration: duration} = game)
       when length(rounds) == duration - 1 do
    %{game | current_round: nil, rounds: [round | rounds]}
  end

  defp finish_round(%Game{current_round: round, rounds: rounds} = game) do
    %{game | current_round: %Round{}, rounds: [round | rounds]}
  end

  defp maybe_update_result(%Game{rounds: rounds, duration: duration} = game)
       when length(rounds) < duration do
    game
  end

  defp maybe_update_result(%Game{first_player_score: score, second_player_score: score} = game) do
    %{game | result: :draw}
  end

  defp maybe_update_result(
         %Game{first_player_score: first_player_score, second_player_score: second_player_score} =
           game
       )
       when first_player_score > second_player_score do
    %{game | result: :first}
  end

  defp maybe_update_result(game) do
    %{game | result: :second}
  end
end

defimpl Inspect, for: Rps.Game do
  def inspect(game, _opts), do: "#Game<" <> Rps.Game.to_doc(game) <> ">"
end
