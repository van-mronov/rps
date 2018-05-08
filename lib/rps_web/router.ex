defmodule RPSWeb.Router do
  use RPSWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", RPSWeb do
    pipe_through :api
  end
end
