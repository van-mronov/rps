defmodule RpsWeb.UserControllerTest do
  use RpsWeb.ConnCase

  import RpsWeb.AuthCase
  alias Rps.Accounts

  @create_attrs %{name: "Ivan", password: "super_sequre_pass"}
  @update_attrs %{name: "Maria", password: "updated_super_sequre_pass"}
  @invalid_attrs %{name: nil, password: nil}

  setup %{conn: conn} = config do
    if name = config[:login] do
      user = add_user(name)
      other = add_user("Maria")
      conn = conn |> add_token_conn(user)
      {:ok, %{conn: conn, user: user, other: other}}
    else
      {:ok, %{conn: conn}}
    end
  end

  describe "index" do
    @tag login: "Ivan"
    test "lists all entries on index", %{conn: conn} do
      conn = get(conn, user_path(conn, :index))
      assert json_response(conn, 200)
    end

    test "renders /users error for unauthorized user", %{conn: conn} do
      conn = get(conn, user_path(conn, :index))
      assert json_response(conn, 401)
    end
  end

  describe "show user" do
    @tag login: "Ivan"
    test "show chosen user's page", %{conn: conn, user: user} do
      conn = get(conn, user_path(conn, :show, user))
      assert json_response(conn, 200)["data"] == %{"id" => user.id, "name" => "Ivan"}
    end
  end

  describe "create user" do
    test "creates user when data is valid", %{conn: conn} do
      conn = post(conn, user_path(conn, :create), user: @create_attrs)
      assert json_response(conn, 201)["data"]["id"]
      assert Accounts.get_by(%{"name" => "Ivan"})
    end

    test "does not create user and renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    @tag login: "Ivan"
    test "updates chosen user when data is valid", %{conn: conn, user: user} do
      conn = put(conn, user_path(conn, :update, user), user: @update_attrs)
      assert json_response(conn, 200)["data"]["id"] == user.id
      updated_user = Accounts.get(user.id)
      assert updated_user.name == "Maria"
    end

    @tag login: "Ivan"
    test "does not update chosen user and renders errors when data is invalid", %{
      conn: conn,
      user: user
    } do
      conn = put(conn, user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    @tag login: "Ivan"
    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, user_path(conn, :delete, user))
      assert response(conn, 204)
      refute Accounts.get(user.id)
    end

    @tag login: "Ivan"
    test "cannot delete other user", %{conn: conn, other: other} do
      conn = delete(conn, user_path(conn, :delete, other))
      assert json_response(conn, 403)["errors"]["detail"] =~ "not authorized"
      assert Accounts.get(other.id)
    end
  end
end
