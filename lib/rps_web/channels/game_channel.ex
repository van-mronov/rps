defmodule RpsWeb.GameChannel do
  use RpsWeb, :channel

  alias Rps.GameServer

  def join("game:" <> game_name, _params, socket) do
    if GameServer.alive?(game_name) do
      maybe_join_game(game_name, socket)
    else
      {:error, %{reason: "Game does not exist"}}
    end
  end

  def handle_info({:after_join, game_name}, socket) do
    broadcast!(socket, "game_info", GameServer.info(game_name))
    {:noreply, socket}
  end

  def handle_in("turn", %{"choice" => choice}, socket) do
    "game:" <> game_name = socket.topic

    if GameServer.alive?(game_name) do
      game_info = Rps.game_turn(game_name, socket.assigns.user_id, choice)
      broadcast!(socket, "game_info", game_info)
      {:noreply, socket}
    else
      {:reply, {:error, %{reason: "Game does not exist"}}, socket}
    end
  end

  defp maybe_join_game(game_name, socket) do
    case Rps.join_game(game_name, socket.assigns.user_id) do
      :ok ->
        send(self(), {:after_join, game_name})
        {:ok, socket}

      {:error, :another_player_already_joined} ->
        {:error, %{reason: "Another player has already joined"}}
    end
  end
end
