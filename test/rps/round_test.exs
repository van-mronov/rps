defmodule RPS.RoundTest do
  use ExUnit.Case
  doctest RPS.Round

  alias RPS.Round

  describe "new/0" do
    test "returns a blank round" do
      assert Round.new() == %Round{first_player_choice: nil, second_player_choice: nil, result: nil}
    end
  end

  describe "rock beats scissors in update_result/1 and" do
    test "result is `:first` if first player chose `:rock`" do
      round =
        Round.new()
        |> Round.player_choice(:first, :rock)
        |> Round.player_choice(:second, :scissors)
        |> Round.update_result()

      assert round.result == :first
    end

    test "result is `:second` if second player chose `:rock`" do
      round =
        Round.new()
        |> Round.player_choice(:first, :scissors)
        |> Round.player_choice(:second, :rock)
        |> Round.update_result()

      assert round.result == :second
    end
  end
end
