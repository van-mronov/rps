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

  def id(socket), do: "user_socket:#{socket.assigns.user_id}"
end
