defmodule SqueezeWeb.Api.FollowView do
  use SqueezeWeb, :view

  alias SqueezeWeb.Api.UserView

  def render("followers.json", %{users: users}) do
    %{followers: render_many(users, UserView, "user.json", as: :user)}
  end

  def render("following.json", %{users: users}) do
    %{following: render_many(users, UserView, "user.json", as: :user)}
  end

  def render("follow.json", _) do
    %{}
  end
end
