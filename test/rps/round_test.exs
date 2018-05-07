defmodule RPS.RoundTest do
  use ExUnit.Case
  doctest RPS.Round

  alias RPS.Round

  describe "new/0" do
    test "returns a blank round" do
      assert Round.new() == %Round{first_player_choice: nil, second_player_choice: nil, result: nil}
    end
  end
end
