defmodule SqueezeWeb.Api.UserView do
  def render("user.json", %{user: user, token: token}) do
    %{
      user: %{
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        id: user.id
      },
      token: token
    }
  end
end
