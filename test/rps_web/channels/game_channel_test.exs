defmodule RpsWeb.GameChannelTest do
  use RpsWeb.ChannelCase

  import RpsWeb.AuthCase
  alias Rps.GameServer
  alias RpsWeb.GameChannel

  setup do
    user = add_user("Ivan")
    token = Phauxth.Token.sign(RpsWeb.Endpoint, user.id)
    {:ok, socket} = connect(RpsWeb.UserSocket, %{"access_token" => token})
    {:ok, game_name} = Rps.start_game(user.id)
    topic = "game:" <> game_name

    second_palyer = add_user("Maria")
    second_palyer_token = Phauxth.Token.sign(RpsWeb.Endpoint, second_palyer.id)
    {:ok, second_palyer_socket} = connect(RpsWeb.UserSocket, %{"access_token" => second_palyer_token})

    other_user = add_user("Vadim")
    other_user_token = Phauxth.Token.sign(RpsWeb.Endpoint, other_user.id)
    {:ok, other_user_socket} = connect(RpsWeb.UserSocket, %{"access_token" => other_user_token})

    {:ok,
     user: user,
     socket: socket,
     game_name: game_name,
     topic: topic,
     second_palyer: second_palyer,
     second_palyer_socket: second_palyer_socket,
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
      {:ok, _reply, socket} = join(context.second_palyer_socket, context.topic)
      assert socket.joined
    end

    test "replies with status error if the third player tries to join to the game", context do
      {:ok, _reply, _socket} = join(context.second_palyer_socket, context.topic)
      error_message = {:error, %{reason: "Another player has already joined"}}
      assert join(context.other_user_socket, context.topic) == error_message
    end
  end
end