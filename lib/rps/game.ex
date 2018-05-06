defmodule RPS.Game do

  alias RPS.{Game, Round}

  defstruct current_round: %Round{}, rounds: [], first_player_score: 0, second_player_score: 0, result: nil

  @duration 10

  @doc """
  Creates a new game.
  """
  def new do
    %Game{}
  end

  def first_player_choice(game, choice) do
    update_round_with_player_choice(game, :first, choice)
  end

  def second_player_choice(game, choice) do
    game
    |> update_round_with_player_choice(:second, choice)
    |> update_round_result()
    |> update_scores()
    |> finish_round()
    |> maybe_update_result()
  end

  defp update_round_with_player_choice(%Game{current_round: round} = game, player_position, choice) do
    %{game | current_round: Round.player_choice(round, player_position, choice)}
  end

  defp update_round_result(%Game{current_round: round} = game) do
    %{game | current_round: Round.update_result(round)}
  end

  defp update_scores(%Game{current_round: %Round{result: :first}, first_player_score: score} = game) do
    %{game | first_player_score: score + 1}
  end

  defp update_scores(%Game{current_round: %Round{result: :second}, second_player_score: score} = game) do
    %{game | second_player_score: score + 1}
  end

  defp update_scores(game) do
    game
  end

  defp finish_round(%Game{current_round: round, rounds: rounds} = game) when length(rounds) == @duration - 1 do
    %{game | current_round: nil, rounds: [round | rounds]}
  end

  defp finish_round(%Game{current_round: round, rounds: rounds} = game) do
    %{game | current_round: %Round{}, rounds: [round | rounds]}
  end

  defp maybe_update_result(%Game{rounds: rounds} = game) when length(rounds) < @duration do
    game
  end

  defp maybe_update_result(%Game{first_player_score: score, second_player_score: score} = game) do
    %{game | result: :draw}
  end

  defp maybe_update_result(%Game{first_player_score: first_player_score, second_player_score: second_player_score} = game) when first_player_score > second_player_score do
    %{game | result: :first}
  end

  defp maybe_update_result(game) do
    %{game | result: :second}
  end
end
