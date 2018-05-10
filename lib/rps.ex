defmodule Rps do
  @moduledoc """
  Rps keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def start_game(user_id) do
    game_name = Rps.HaikuName.generate()
    user = Rps.Accounts.get_user!(user_id)
    case Rps.GameSupervisor.start_game(game_name, user) do
      {:ok, _pid} ->
        {:ok, game_name}

      error ->
        error
    end
  end

  def join_game(game_name, user_id) do
    user = Rps.Accounts.get_user!(user_id)
    Rps.GameServer.join(game_name, user)
  end
end
