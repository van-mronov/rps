defmodule RpsWeb.GameChannelTest do
  use RpsWeb.ChannelCase

  import RpsWeb.AuthCase
  alias Rps.GameServer
  alias RpsWeb.GameChannel

  @move_timeout_offset_ms 100

  setup do
    Rps.Leaderboard.clear()

    user = add_user("Ivan")
    token = Phauxth.Token.sign(RpsWeb.Endpoint, user.id)
    {:ok, socket} = connect(RpsWeb.UserSocket, %{"access_token" => token})
    {:ok, game_name} = Rps.start_game(user.id)
    topic = "game:" <> game_name

    second_player = add_user("Maria")
    second_player_token = Phauxth.Token.sign(RpsWeb.Endpoint, second_player.id)
    {:ok, second_player_socket} = connect(RpsWeb.UserSocket, %{"access_token" => second_player_token})

    other_user = add_user("Vadim")
    other_user_token = Phauxth.Token.sign(RpsWeb.Endpoint, other_user.id)
    {:ok, other_user_socket} = connect(RpsWeb.UserSocket, %{"access_token" => other_user_token})

    {:ok,
     user: user,
     socket: socket,
     game_name: game_name,
     topic: topic,
     second_player: second_player,
     second_player_socket: second_player_socket,
     other_user: other_user,
     other_user_socket: other_user_socket}
  end

  describe "join" do
    test "replies with status error if there is no such game", %{socket: socket} do
      assert join(socket, "game:invalid_game_name") == {:error, %{reason: "Game does not exist"}}
    end

    test "replies with status ok for the creator of the game", %{socket: socket, topic: topic} do
      {:ok, _reply, socket} = join(socket, topic)
      assert socket.joined
    end

    test "pushes the current game info", context do
      {:ok, _reply, _socket} = subscribe_and_join(context.socket, GameChannel, context.topic, %{})
      game_info = GameServer.info(context.game_name)
      assert_push("game_info", ^game_info)
    end

    test "replies with status ok for the second player of the game", context do
      {:ok, _reply, socket} = join(context.second_player_socket, context.topic)
      assert socket.joined
    end

    test "replies with status error if the third player tries to join to the game", context do
      {:ok, _reply, _socket} = join(context.second_player_socket, context.topic)
      error_message = {:error, %{reason: "Another player has already joined"}}
      assert join(context.other_user_socket, context.topic) == error_message
    end

    test "pushes the current game info after the second player joins the game", context do
      {:ok, _reply, _socket} = subscribe_and_join(context.socket, GameChannel, context.topic, %{})
      assert_broadcast("game_info", %{})
      {:ok, _reply, _socket} = join(context.second_player_socket, context.topic)
      game_info = GameServer.info(context.game_name)
      assert_push("game_info", ^game_info)
    end
  end

  describe "move" do
    test "pushes the current game info", context do
      {:ok, _reply, socket1} = subscribe_and_join(context.socket, GameChannel, context.topic, %{})
      assert_broadcast("game_info", %{})
      {:ok, _reply, _socket2} = join(context.second_player_socket, context.topic)
      assert_broadcast("game_info", %{})
      push(socket1, "move", %{"choice" => "rock"})
      assert_broadcast("game_info", payload)
      assert payload.current_round.first_player_choice == :rock
    end

    test "of the second player finishes the current round", context do
      {:ok, _reply, socket1} = subscribe_and_join(context.socket, GameChannel, context.topic, %{})
      assert_broadcast("game_info", %{})
      {:ok, _reply, socket2} = join(context.second_player_socket, context.topic)
      assert_broadcast("game_info", %{})

      push(socket1, "move", %{"choice" => "rock"})
      assert_broadcast("game_info", payload)
      assert payload.current_round.first_player_choice == :rock

      push(socket2, "move", %{"choice" => "paper"})
      assert_broadcast("game_info", payload)
      finished_round = List.first(payload.rounds)
      assert finished_round.second_player_choice == :paper
      assert finished_round.result == :second
    end

    test "of the second player updates scores", context do
      {:ok, _reply, socket1} = subscribe_and_join(context.socket, GameChannel, context.topic, %{})
      assert_broadcast("game_info", %{})
      {:ok, _reply, socket2} = join(context.second_player_socket, context.topic)
      assert_broadcast("game_info", %{})

      push(socket1, "move", %{"choice" => "rock"})
      assert_broadcast("game_info", payload)
      assert payload.current_round.first_player_choice == :rock

      push(socket2, "move", %{"choice" => "paper"})
      assert_broadcast("game_info", payload)
      assert payload.second_player.score == 1
    end
  end

  describe "move of the second player of the last round" do
    test "broadcasts `:game_over` with the game result", context do
      {:ok, _reply, socket1} = subscribe_and_join(context.socket, GameChannel, context.topic, %{})
      assert_broadcast("game_info", %{})
      {:ok, _reply, socket2} = join(context.second_player_socket, context.topic)
      assert_broadcast("game_info", %{})
      assert_broadcast("game_started", %{})

      Enum.each(1..4, fn round_number ->
        push(socket1, "move", %{"choice" => "rock"})
        assert_broadcast("opponent_move", %{})
        assert_broadcast("game_info", %{})

        push(socket2, "move", %{"choice" => "paper"})
        if round_number == 4 do
          assert_broadcast("game_over", game_info)
          assert not is_nil(game_info.result)
        else
          assert_broadcast("opponent_move", %{})
          assert_broadcast("game_info", %{})
        end
      end)
    end

    test "broadcasts leaderboard into lobby channel", context do
      {:ok, _reply, socket1} = subscribe_and_join(context.socket, "game:lobby")
      {:ok, _reply, socket1} = subscribe_and_join(socket1, GameChannel, context.topic, %{})
      assert_broadcast("game_info", %{})
      {:ok, _reply, socket2} = join(context.second_player_socket, context.topic)
      assert_broadcast("game_info", %{})
      assert_broadcast("game_started", %{})

      Enum.each(1..4, fn round_number ->
        push(socket1, "move", %{"choice" => "rock"})
        assert_broadcast("opponent_move", %{})
        assert_broadcast("game_info", %{})

        push(socket2, "move", %{"choice" => "paper"})
        if round_number == 4 do
          assert_broadcast("game_over", game_info)
          assert game_info.result == :second
          assert_broadcast("leaderboard", leaderboard)
          [the_best_player, the_second_player | _tail] = leaderboard.table
          assert the_best_player.id == context.second_player.id
          assert the_second_player.id == context.user.id
        else
          assert_broadcast("opponent_move", %{})
          assert_broadcast("game_info", %{})
        end
      end)
    end
  end

  test "if user didn’t make a choice system will randomly choose one", context do
    {:ok, _reply, _socket1} = subscribe_and_join(context.socket, GameChannel, context.topic, %{})
    assert_broadcast("game_info", %{})
    {:ok, _reply, _socket2} = join(context.second_player_socket, context.topic)
    assert_broadcast("game_info", %{})
    assert_broadcast("game_started", %{})
    move_timeout = Application.get_env(:rps, :move_timeout)
    assert_broadcast("opponent_move", %{}, move_timeout + @move_timeout_offset_ms)
    assert_broadcast("game_info", payload)
    assert not is_nil(payload.current_round.first_player_choice)
  end
end
