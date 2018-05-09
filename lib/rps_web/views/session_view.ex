defmodule RpsWeb.SessionView do
  use RpsWeb, :view

  def render("info.json", %{info: token}) do
    %{access_token: token}
  end
end
