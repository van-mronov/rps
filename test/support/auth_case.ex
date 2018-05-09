defmodule RpsWeb.AuthCase do
  use Phoenix.ConnTest

  # alias Rps.Accounts

  def add_user(name) do
    user = %{name: name, password: "super_sequre_pass"}
    {:ok, user} = Rps.Accounts.create_user(user)
    user
  end

  def add_token_conn(conn, user) do
    user_token = Phauxth.Token.sign(RpsWeb.Endpoint, user.id)

    conn
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", user_token)
  end

  def gen_key(name) do
    Phauxth.Token.sign(RpsWeb.Endpoint, %{"name" => name})
  end
end
