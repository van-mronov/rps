defmodule RPS.RoundTest do
  use ExUnit.Case
  doctest RPS.Round

  alias RPS.Round

  describe "new/0" do
    test "returns a blank round" do
      assert Round.new() == %Round{
               first_player_choice: nil,
               second_player_choice: nil,
               result: nil
             }
    end
  end

  describe "player_choice/3" do
    test "updates first player choice with specified choice" do
      round = Round.player_choice(Round.new(), :first, :rock)
      assert round.first_player_choice == :rock
    end

    test "updates second player choice with specified choice" do
      round = Round.player_choice(Round.new(), :second, :rock)
      assert round.second_player_choice == :rock
    end
  end

  describe "rock beats scissors in update_result/1 and" do
    test "result is `:first` if the first player chose `:rock`" do
      round =
        Round.new()
        |> Round.player_choice(:first, :rock)
        |> Round.player_choice(:second, :scissors)
        |> Round.update_result()

      assert round.result == :first
    end

    test "result is `:second` if the second player chose `:rock`" do
      round =
        Round.new()
        |> Round.player_choice(:first, :scissors)
        |> Round.player_choice(:second, :rock)
        |> Round.update_result()

      assert round.result == :second
    end
  end

  describe "scissors beats paper in update_result/1 and" do
    test "result is `:first` if the first player chose `:scissors`" do
      round =
        Round.new()
        |> Round.player_choice(:first, :scissors)
        |> Round.player_choice(:second, :paper)
        |> Round.update_result()

      assert round.result == :first
    end

    test "result is `:second` if the second player chose `:scissors`" do
      round =
        Round.new()
        |> Round.player_choice(:first, :paper)
        |> Round.player_choice(:second, :scissors)
        |> Round.update_result()

      assert round.result == :second
    end
  end

  describe "paper beats rock in update_result/1 and" do
    test "result is `:first` if the first player chose `:paper`" do
      round =
        Round.new()
        |> Round.player_choice(:first, :paper)
        |> Round.player_choice(:second, :rock)
        |> Round.update_result()

      assert round.result == :first
    end

    test "result is `:second` if the second player chose `:paper`" do
      round =
        Round.new()
        |> Round.player_choice(:first, :rock)
        |> Round.player_choice(:second, :paper)
        |> Round.update_result()

      assert round.result == :second
    end
  end

  describe "update_result/1 set result as `:draw`" do
    test "if both players chose `:rock`" do
      round =
        Round.new()
        |> Round.player_choice(:first, :rock)
        |> Round.player_choice(:second, :rock)
        |> Round.update_result()

      assert round.result == :draw
    end

    test "if both players chose `:paper`" do
      round =
        Round.new()
        |> Round.player_choice(:first, :paper)
        |> Round.player_choice(:second, :paper)
        |> Round.update_result()

      assert round.result == :draw
    end

    test "if both players chose `:scissors`" do
      round =
        Round.new()
        |> Round.player_choice(:first, :scissors)
        |> Round.player_choice(:second, :scissors)
        |> Round.update_result()

      assert round.result == :draw
    end
  end
end
