defmodule SqueezeWeb.Api.UserView do
  use SqueezeWeb, :view

  def render("user.json", %{user: user, token: token}) do
    %{
      user: %{
        id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        description: user.description,
        avatar: user.avatar,
        city: user.city,
        state: user.state,
        country: user.country
      },
      token: token
    }
  end
end
