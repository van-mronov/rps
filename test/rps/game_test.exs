defmodule Rps.GameTest do
  use ExUnit.Case
  doctest Rps.Game

  alias Rps.{Game, Round}

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
        Rps.Game.new()
        |> Rps.Game.first_player_choice(:rock)
        |> Rps.Game.second_player_choice(:scissors)

      assert List.first(game.rounds) == %Round{
               first_player_choice: :rock,
               second_player_choice: :scissors,
               result: :first
             }
    end

    test "starts the new round" do
      game =
        Rps.Game.new()
        |> Rps.Game.first_player_choice(:rock)
        |> Rps.Game.second_player_choice(:scissors)

      assert game.current_round == %Round{}
    end
  end

  describe "second_player_choice/2 of the 10th round" do
    test "finishes the game" do
      game =
        Enum.reduce(1..4, Rps.Game.new(), fn _round_number, game ->
          game
          |> Rps.Game.first_player_choice(:rock)
          |> Rps.Game.second_player_choice(:scissors)
        end)

      assert game.current_round == nil
    end

    test "marks the first player as a winner if he/she won more rounds than the second player" do
      game =
        Enum.reduce(1..3, Rps.Game.new(), fn _round_number, game ->
          game
          |> Rps.Game.first_player_choice(:rock)
          |> Rps.Game.second_player_choice(:scissors)
        end)

      game =
        game
        |> Rps.Game.first_player_choice(:paper)
        |> Rps.Game.second_player_choice(:scissors)

      assert game.result == :first
    end

    test "marks the second player as a winner if he/she won more rounds than the first player" do
      game =
        Rps.Game.new()
        |> Rps.Game.first_player_choice(:rock)
        |> Rps.Game.second_player_choice(:scissors)

      game =
        Enum.reduce(1..3, game, fn _round_number, game ->
          game
          |> Rps.Game.first_player_choice(:paper)
          |> Rps.Game.second_player_choice(:scissors)
        end)

      assert game.result == :second
    end

    test "sets the result of the game as `:draw` if both players won 5 rounds" do
      game =
        Enum.reduce(1..2, Rps.Game.new(), fn _round_number, game ->
          game
          |> Rps.Game.first_player_choice(:rock)
          |> Rps.Game.second_player_choice(:scissors)
        end)

      game =
        Enum.reduce(1..2, game, fn _round_number, game ->
          game
          |> Rps.Game.first_player_choice(:paper)
          |> Rps.Game.second_player_choice(:scissors)
        end)

      assert game.result == :draw
    end
  end

  describe "second_player_choice/2 increments the first player's score" do
    test "if he/she chose `:rock` and the second player chose `:scissors`" do
      game =
        Rps.Game.new()
        |> Rps.Game.first_player_choice(:rock)
        |> Rps.Game.second_player_choice(:scissors)

      assert game.first_player_score == 1
    end

    test "if he/she chose `:scissors` and the second player chose `:paper`" do
      game =
        Rps.Game.new()
        |> Rps.Game.first_player_choice(:scissors)
        |> Rps.Game.second_player_choice(:paper)

      assert game.first_player_score == 1
    end

    test "if he/she chose `:paper` and the second player chose `:rock`" do
      game =
        Rps.Game.new()
        |> Rps.Game.first_player_choice(:paper)
        |> Rps.Game.second_player_choice(:rock)

      assert game.first_player_score == 1
    end
  end

  describe "second_player_choice/2 increments the second player's score" do
    test "if he/she chose `:rock` and the first player chose `:scissors`" do
      game =
        Rps.Game.new()
        |> Rps.Game.first_player_choice(:scissors)
        |> Rps.Game.second_player_choice(:rock)

      assert game.second_player_score == 1
    end

    test "if he/she chose `:scissors` and the first player chose `:paper`" do
      game =
        Rps.Game.new()
        |> Rps.Game.first_player_choice(:paper)
        |> Rps.Game.second_player_choice(:scissors)

      assert game.second_player_score == 1
    end

    test "if he/she chose `:paper` and the first player chose `:rock`" do
      game =
        Rps.Game.new()
        |> Rps.Game.first_player_choice(:rock)
        |> Rps.Game.second_player_choice(:paper)

      assert game.second_player_score == 1
    end
  end
end
