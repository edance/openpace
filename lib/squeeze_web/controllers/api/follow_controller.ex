defmodule SqueezeWeb.Api.FollowController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts
  alias Squeeze.Social
  alias Squeeze.Social.Follow

  action_fallback SqueezeWeb.Api.FallbackController

  def followers(conn, %{"slug" => slug}) do
    user = Accounts.get_user_by_slug!(slug)
    followers = Social.list_followers(user)
    render(conn, "followers.json", users: followers)
  end

  def following(conn, %{"slug" => slug}) do
    user = Accounts.get_user_by_slug!(slug)
    following = Social.list_following(user)
    render(conn, "following.json", users: following)
  end

  def follow(conn, %{"slug" => slug}) do
    user = conn.assigns.current_user
    followee = Accounts.get_user_by_slug!(slug)

    with {:ok, _} <- Social.follow(user, followee) do
      conn
      |> put_status(:created)
      |> render("follow.json")
    end
  end

  def unfollow(conn, %{"slug" => slug}) do
    user = conn.assigns.current_user
    followee = Accounts.get_user_by_slug!(slug)

    with {:ok, %Follow{}} <- Social.unfollow(user, followee) do
      send_resp(conn, :no_content, "")
    end
  end
end
