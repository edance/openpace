defmodule SqueezeWeb.Api.GoogleAuthView do
  use SqueezeWeb, :view

  def render("auth.json", %{token: token}) do
    %{
      token: token
    }
  end
end
