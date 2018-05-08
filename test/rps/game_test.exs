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
end
