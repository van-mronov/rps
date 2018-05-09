defmodule RpsWeb.UserSocketTest do
  use RpsWeb.ChannelCase, async: true

  import RpsWeb.AuthCase
  alias RpsWeb.UserSocket

  setup do
    user = add_user("Ivan")
    token = Phauxth.Token.sign(RpsWeb.Endpoint, user.id)
    {:ok, user: user, token: token}
  end

  describe "connect/2" do
    test "disable connection for unauthenticated users" do
      assert connect(UserSocket, %{"access_token" => "invalid_token"}) == :error
    end

    test "assigns user_id for authenticated users", %{user: user, token: token} do
      {:ok, socket} = connect(UserSocket, %{"access_token" => token})
      assert socket.assigns.user_id == user.id
    end
  end

  describe "id/1" do
    test "allows to identify all sockets for a given user" , %{user: user, token: token} do
      {:ok, socket} = connect(UserSocket, %{"access_token" => token})
      assert socket.id == "user_socket:#{user.id}"
    end
  end
end
