defmodule RpsWeb.UserSocket do
  use Phoenix.Socket
  require Logger

  ## Channels
  # channel "room:*", RpsWeb.RoomChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket

  def connect(%{"access_token" => token}, socket) do
    case Phauxth.Token.verify(socket, token, 86400) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}
      error ->
        error |> inspect() |> Logger.warn()
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     RpsWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
