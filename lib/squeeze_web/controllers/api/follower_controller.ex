defmodule SqueezeWeb.Api.FollowerController do
  use SqueezeWeb, :controller

  alias Squeeze.Social
  alias Squeeze.Social.Follower

  action_fallback SqueezeWeb.Api.FallbackController

  def index(conn, %{"id" => user_id}) do
    followers = Social.list_followers(user_id)
    render(conn, "index.json", followers: followers)
  end

  def create(conn, %{"id" => user_id}) do
    user = conn.assigns.current_user

    with {:ok, %Follower{} = follower} <- Social.create_follower(user, user_id) do
      conn
      |> put_status(:created)
      |> render("show.json", follower: follower)
    end
  end

  def delete(conn, %{"id" => user_id}) do
    user = conn.assigns.current_user

    with {:ok, %Follower{}} <- Social.delete_follower(user, user_id) do
      send_resp(conn, :no_content, "")
    end
  end
end
