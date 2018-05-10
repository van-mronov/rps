defmodule RpsWeb.GameChannelTest do
  use RpsWeb.ChannelCase

  import RpsWeb.AuthCase

  setup do
    user = add_user("Ivan")
    token = Phauxth.Token.sign(RpsWeb.Endpoint, user.id)
    {:ok, socket} = connect(RpsWeb.UserSocket, %{"access_token" => token})
    {:ok, game_name} = Rps.start_game(user.id)
    {:ok, user: user, token: token, socket: socket, game_name: game_name}
  end

  describe "join" do
    test "replies with status error if there is no such game", %{socket: socket} do
      assert join(socket, "game:invalid_game_name") == {:error, %{reason: "Game does not exist"}}
    end

    test "replies with status ok for creator of the game", context do
      {:ok, %{}, socket} = join(context.socket, "game:" <> context.game_name)
      assert socket.joined
    end
  end
end
