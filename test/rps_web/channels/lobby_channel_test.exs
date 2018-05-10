defmodule RpsWeb.LobbyChannelTest do
  use RpsWeb.ChannelCase

  import RpsWeb.AuthCase

  setup do
    user = add_user("Ivan")
    token = Phauxth.Token.sign(RpsWeb.Endpoint, user.id)
    {:ok, socket} = connect(RpsWeb.UserSocket, %{"access_token" => token})
    {:ok, user: user, token: token, socket: socket}
  end

  test "authenticated users can join to lobby channel", %{socket: socket} do
    {:ok, _, socket} = join(socket, "lobby:lobby")
    assert socket.joined
  end

  test "new_game replies with status ok", %{socket: socket} do
    {:ok, _, socket} = subscribe_and_join(socket, "lobby:lobby")
    ref = push socket, "new_game", %{}
    assert_reply ref, :ok, %{game_name: _game_name}
  end
end
