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
    {:ok, user: user, token: token, socket: socket, game_name: game_name, topic: topic}
  end

  describe "join" do
    test "replies with status error if there is no such game", %{socket: socket} do
      assert join(socket, "game:invalid_game_name") == {:error, %{reason: "Game does not exist"}}
    end

    test "replies with status ok for creator of the game", %{socket: socket, topic: topic} do
      {:ok, _reply, socket} = join(socket, topic)
      assert socket.joined
    end

    test "pushes the current game info", context do
      {:ok, _reply, _socket} = subscribe_and_join(context.socket, GameChannel, context.topic, %{})
      game_info = GameServer.info(context.game_name)
      assert_push("game_info", ^game_info)
    end
  end
end
