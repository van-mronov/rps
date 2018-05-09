defmodule RpsWeb.Router do
  use RpsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Phauxth.Authenticate, method: :token
  end

  scope "/api", RpsWeb do
    pipe_through :api

    post "/sessions", SessionController, :create

    resources "/users", UserController, except: [:new, :edit]
  end
end
