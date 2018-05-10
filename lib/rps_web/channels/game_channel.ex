defmodule RpsWeb.GameChannel do
  use RpsWeb, :channel

  alias Rps.GameServer

  intercept ["game_started", "opponent_move"]

  def join("game:" <> game_name, _params, socket) do
    if GameServer.alive?(game_name) do
      maybe_join_game(game_name, socket)
    else
      {:error, %{reason: "Game does not exist"}}
    end
  end

  def handle_info({:after_join, game_name, player_position}, socket) do
    if player_position == :second, do: broadcast_from!(socket, "game_started", %{})
    broadcast!(socket, "game_info", GameServer.info(game_name))
    {:noreply, socket}
  end

  def handle_info(:move_timeout, socket) do
    "game:" <> game_name = socket.topic

    if GameServer.alive?(game_name) do
      do_move(game_name, random_choice(), socket)
    end

    {:noreply, socket}
  end

  def handle_in("move", %{"choice" => choice}, socket) do
    Process.cancel_timer(socket.assigns.timer)
    "game:" <> game_name = socket.topic

    if GameServer.alive?(game_name) do
      do_move(game_name, choice, socket)
      {:noreply, socket}
    else
      {:reply, {:error, %{reason: "Game does not exist"}}, socket}
    end
  end

  def handle_out(event, msg, socket) when event in ~w(game_started opponent_move) do
    move_timeout = Application.get_env(:rps, :move_timeout)
    timer = Process.send_after(self(), :move_timeout, move_timeout)
    push(socket, event, msg)
    {:noreply, assign(socket, :timer, timer)}
  end

  defp maybe_join_game(game_name, socket) do
    case Rps.join_game(game_name, socket.assigns.user_id) do
      {:ok, player_position} ->
        send(self(), {:after_join, game_name, player_position})
        {:ok, socket}

      {:error, :another_player_already_joined} ->
        {:error, %{reason: "Another player has already joined"}}
    end
  end

  defp do_move(game_name, choice, socket) do
    game_info = Rps.game_move(game_name, socket.assigns.user_id, choice)
    broadcast_from!(socket, "opponent_move", %{})
    broadcast!(socket, "game_info", game_info)
  end

  defp random_choice do
    ~w(rock paper scissors)
    |> Enum.shuffle()
    |> List.first()
  end
end
