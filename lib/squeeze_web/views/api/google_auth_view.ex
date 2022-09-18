defmodule SqueezeWeb.Api.GoogleAuthView do
  use SqueezeWeb, :view
  @moduledoc false

  def render("auth.json", %{token: token}) do
    %{
      token: token
    }
  end
end
