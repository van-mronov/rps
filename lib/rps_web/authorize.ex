defmodule RpsWeb.Authorize do
  import Plug.Conn
  import Phoenix.Controller

  # Plug to only allow unauthenticated users to access the resource.
  # See the session controller for an example.
  def guest_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts), do: conn

  def guest_check(%Plug.Conn{assigns: %{current_user: _current_user}} = conn, _opts) do
    put_status(conn, :unauthorized)
    |> render(RpsWeb.AuthView, "logged_in.json", [])
    |> halt
  end

  def error(conn, status, code) do
    put_status(conn, status)
    |> render(RpsWeb.AuthView, "#{code}.json", [])
    |> halt
  end
end
