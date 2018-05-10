defmodule RpsWeb.GameChannel do
  use RpsWeb, :channel

  alias Rps.GameServer

  def join("game:" <> game_name, _params, socket) do
    if GameServer.alive?(game_name) do
      send(self(), {:after_join, game_name})
      {:ok, socket}
    else
      {:error, %{reason: "Game does not exist"}}
    end
  end

  def handle_info({:after_join, game_name}, socket) do
    push(socket, "game_info", GameServer.info(game_name))
    {:noreply, socket}
  end
end
