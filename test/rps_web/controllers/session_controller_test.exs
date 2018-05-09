defmodule RpsWeb.SessionControllerTest do
  use RpsWeb.ConnCase

  import RpsWeb.AuthCase

  @create_attrs %{name: "Ivan", password: "super_sequre_pass"}
  @invalid_attrs %{name: "Ivan", password: "invalid_pass"}

  setup %{conn: conn} do
    user = add_user("Ivan")
    {:ok, %{conn: conn, user: user}}
  end

  describe "create session" do
    test "login succeeds", %{conn: conn} do
      conn = post(conn, session_path(conn, :create), session: @create_attrs)
      assert json_response(conn, 200)["access_token"]
    end

    test "login fails for user that is already logged in", %{conn: conn, user: user} do
      conn = conn |> add_token_conn(user)
      conn = post(conn, session_path(conn, :create), session: @create_attrs)
      assert json_response(conn, 401)["errors"]["detail"] =~ "already logged in"
    end

    test "login fails for invalid password", %{conn: conn} do
      conn = post(conn, session_path(conn, :create), session: @invalid_attrs)
      assert json_response(conn, 401)["errors"]["detail"] =~ "need to login"
    end
  end
end
