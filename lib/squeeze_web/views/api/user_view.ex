defmodule SqueezeWeb.Api.UserView do
  use SqueezeWeb, :view

  def render("auth.json", %{user: user, token: token}) do
    %{
      user: render_one(user, SqueezeWeb.Api.UserView, "user.json"),
      token: token
    }
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      description: user.description,
      avatar: user.avatar,
      city: user.city,
      state: user.state,
      country: user.country,
      credentials: render_many(user.credentials, SqueezeWeb.Api.UserView, "credential.json", as: :credential)
    }
  end

  def render("credential.json", %{credential: credential}) do
    %{
      provider: credential.provider,
      uid: credential.uid
    }
  end
end
