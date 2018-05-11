defmodule RpsWeb.LobbyChannel do
  use RpsWeb, :channel

  require Logger

  def join("game:lobby", _payload, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    push(socket, "game_list", Rps.game_list())
    {:noreply, socket}
  end

  def handle_in("new_game", _params, socket) do
    case Rps.start_game(socket.assigns.user_id) do
      {:ok, game_name} ->
        broadcast_from!(socket, "game_list", Rps.game_list())
        {:reply, {:ok, %{game_name: game_name}}, socket}

      error ->
        Logger.warn "Unable to start game: #{inspect error}"
        {:reply, {:error, %{}}, socket}
    end
  end
end
