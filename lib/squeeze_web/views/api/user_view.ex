defmodule SqueezeWeb.Api.UserView do
  def render("user.json", %{user: user, token: token}) do
    %{
      email: user.email,
      token: token
    }
  end
end
