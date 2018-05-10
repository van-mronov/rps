defmodule RpsWeb.LobbyChannel do
  use RpsWeb, :channel

  require Logger

  def join("lobby:lobby", _payload, socket), do: {:ok, socket}

  def handle_in("new_game", _params, socket) do
    case Rps.start_game(socket.assigns.user_id) do
      {:ok, game_name} ->
        {:reply, {:ok, %{game_name: game_name}}, socket}
      error ->
        Logger.warn "Unable to start game: #{inspect error}"
        {:reply, {:error, %{}}, socket}
    end
  end
end
