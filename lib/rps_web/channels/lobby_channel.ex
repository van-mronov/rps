defmodule RpsWeb.LobbyChannel do
  use RpsWeb, :channel

  def join("lobby:lobby", _payload, socket), do: {:ok, socket}
end
