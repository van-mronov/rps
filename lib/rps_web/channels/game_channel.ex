defmodule RpsWeb.GameChannel do
  use RpsWeb, :channel

  alias Rps.GameServer

  def join("game:" <> game_name, _params, socket) do
    if GameServer.alive?(game_name) do
      {:ok, socket}
    else
      {:error, %{reason: "Game does not exist"}}
    end
  end
end
