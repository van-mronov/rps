defmodule RPS.GameTest do
  use ExUnit.Case
  doctest RPS.Game

  alias RPS.{Game, Round}

  describe "new/0" do
    test "returns a blank game" do
      assert Game.new() == %Game{
               current_round: %Round{},
               rounds: [],
               first_player_score: 0,
               second_player_score: 0,
               result: nil
             }
    end
  end

  describe "second_player_choice/2" do
    test "finishes the current round" do
      game =
        RPS.Game.new()
        |> RPS.Game.first_player_choice(:rock)
        |> RPS.Game.second_player_choice(:scissors)

      assert List.first(game.rounds) == %Round{
               first_player_choice: :rock,
               second_player_choice: :scissors,
               result: :first
             }
    end

    test "starts the new round" do
      game =
        RPS.Game.new()
        |> RPS.Game.first_player_choice(:rock)
        |> RPS.Game.second_player_choice(:scissors)

      assert game.current_round == %Round{}
    end
  end

  describe "second_player_choice/2 of the 10th round" do
    test "finishes the game" do
      game =
        Enum.reduce(1..10, RPS.Game.new(), fn _round_number, game ->
          game
          |> RPS.Game.first_player_choice(:rock)
          |> RPS.Game.second_player_choice(:scissors)
        end)

      assert game.current_round == nil
    end

    test "marks the first player as a winner if he/she won more rounds than the second player" do
      game =
        Enum.reduce(1..6, RPS.Game.new(), fn _round_number, game ->
          game
          |> RPS.Game.first_player_choice(:rock)
          |> RPS.Game.second_player_choice(:scissors)
        end)

      game =
        Enum.reduce(1..4, game, fn _round_number, game ->
          game
          |> RPS.Game.first_player_choice(:paper)
          |> RPS.Game.second_player_choice(:scissors)
        end)

      assert game.result == :first
    end
  end

  describe "second_player_choice/2 increments the first player's score" do
    test "if he/she chose `:rock` and the second player chose `:scissors`" do
      game =
        RPS.Game.new()
        |> RPS.Game.first_player_choice(:rock)
        |> RPS.Game.second_player_choice(:scissors)

      assert game.first_player_score == 1
    end

    test "if he/she chose `:scissors` and the second player chose `:paper`" do
      game =
        RPS.Game.new()
        |> RPS.Game.first_player_choice(:scissors)
        |> RPS.Game.second_player_choice(:paper)

      assert game.first_player_score == 1
    end

    test "if he/she chose `:paper` and the second player chose `:rock`" do
      game =
        RPS.Game.new()
        |> RPS.Game.first_player_choice(:paper)
        |> RPS.Game.second_player_choice(:rock)

      assert game.first_player_score == 1
    end
  end

  describe "second_player_choice/2 increments the second player's score" do
    test "if he/she chose `:rock` and the first player chose `:scissors`" do
      game =
        RPS.Game.new()
        |> RPS.Game.first_player_choice(:scissors)
        |> RPS.Game.second_player_choice(:rock)

      assert game.second_player_score == 1
    end

    test "if he/she chose `:scissors` and the first player chose `:paper`" do
      game =
        RPS.Game.new()
        |> RPS.Game.first_player_choice(:paper)
        |> RPS.Game.second_player_choice(:scissors)

      assert game.second_player_score == 1
    end

    test "if he/she chose `:paper` and the first player chose `:rock`" do
      game =
        RPS.Game.new()
        |> RPS.Game.first_player_choice(:rock)
        |> RPS.Game.second_player_choice(:paper)

      assert game.second_player_score == 1
    end
  end
end
