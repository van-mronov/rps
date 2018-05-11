defmodule Rps.LeaderboardTest do
  use ExUnit.Case
  doctest Rps.Leaderboard

  alias Rps.Leaderboard
  alias Rps.Accounts.User

  setup do
    winner = %User{id: 1, name: "Maria"}
    Leaderboard.new_user(winner)

    loser = %User{id: 2, name: "Vadim"}
    Leaderboard.new_user(loser)

    {:ok, winner: winner, loser: loser}
  end

  describe "user_results" do
    test "returns nil if there is no such user" do
      invalid_user = %User{id: 999}
      assert is_nil(Leaderboard.user_results(invalid_user))
    end
  end

  describe "win_game" do
    test "updates winner game_played count", %{winner: winner, loser: loser} do
      %{game_played: game_played} = Leaderboard.user_results(winner)
      Leaderboard.win_game(winner, loser)
      user_results = Leaderboard.user_results(winner)
      assert user_results.game_played == game_played + 1
    end

    test "updates winner won count", %{winner: winner, loser: loser} do
      %{won: won} = Leaderboard.user_results(winner)
      Leaderboard.win_game(winner, loser)
      user_results = Leaderboard.user_results(winner)
      assert user_results.won == won + 1
    end

    test "updates loser game_played count", %{winner: winner, loser: loser} do
      %{game_played: game_played} = Leaderboard.user_results(loser)
      Leaderboard.win_game(winner, loser)
      user_results = Leaderboard.user_results(loser)
      assert user_results.game_played == game_played + 1
    end

    test "updates winner lost count", %{winner: winner, loser: loser} do
      %{lost: lost} = Leaderboard.user_results(loser)
      Leaderboard.win_game(winner, loser)
      user_results = Leaderboard.user_results(loser)
      assert user_results.lost == lost + 1
    end
  end
end
