defmodule SqueezeWeb.Api.UserView do
  use SqueezeWeb, :view
  @moduledoc false

  def render("auth.json", %{user: user, token: token}) do
    %{
      user: render_one(user, SqueezeWeb.Api.UserView, "me.json"),
      token: token
    }
  end

  def render("user.json", %{user: user}) do
    %{
      slug: user.slug,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      description: user.description,
      avatar: user.avatar,
      city: user.city,
      state: user.state,
      country: user.country
    }
  end

  def render("me.json", %{user: user}) do
    %{
      id: user.id,
      slug: user.slug,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      description: user.description,
      avatar: user.avatar,
      city: user.city,
      state: user.state,
      country: user.country,
      credentials: render_many(user.credentials, SqueezeWeb.Api.UserView, "credential.json", as: :credential),
      user_prefs: render_one(user.user_prefs, SqueezeWeb.Api.UserView, "user_prefs.json", as: :user_prefs)
    }
  end

  def render("user_prefs.json", %{user_prefs: user_prefs}) do
    %{
      timezone: user_prefs.timezone,
      imperial: user_prefs.imperial,
      gender: user_prefs.gender,
      birthdate: user_prefs.birthdate
    }
  end

  def render("credential.json", %{credential: credential}) do
    %{
      provider: credential.provider,
      uid: credential.uid
    }
  end
end
