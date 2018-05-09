defmodule RpsWeb.SessionController do
  use RpsWeb, :controller

  import RpsWeb.Authorize
  alias Rps.Accounts
  alias Phauxth.Login

  plug(:guest_check when action in [:create])

  def create(conn, %{"session" => params}) do
    case Login.verify(params, Accounts) do
      {:ok, user} ->
        token = Phauxth.Token.sign(conn, user.id)
        render(conn, "info.json", %{info: token})

      {:error, _message} ->
        error(conn, :unauthorized, 401)
    end
  end
end
