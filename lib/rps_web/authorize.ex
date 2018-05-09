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

  # Plug to only allow authenticated users to access the resource.
  # See the user controller for an example.
  def user_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    error(conn, :unauthorized, 401)
  end

  def user_check(conn, _opts), do: conn

  # Plug to only allow authenticated users with the correct id to access the resource.
  # See the user controller for an example.
  def id_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    error(conn, :unauthorized, 401)
  end

  def id_check(
        %Plug.Conn{params: %{"id" => id}, assigns: %{current_user: current_user}} = conn,
        _opts
      ) do
    (id == to_string(current_user.id) and conn) || error(conn, :forbidden, 403)
  end

  def error(conn, status, code) do
    put_status(conn, status)
    |> render(RpsWeb.AuthView, "#{code}.json", [])
    |> halt
  end
end
