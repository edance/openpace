defmodule SqueezeWeb.Api.FollowController do
  use SqueezeWeb, :controller

  alias Squeeze.Social
  alias Squeeze.Social.Follow

  action_fallback SqueezeWeb.Api.FallbackController

  def index(conn, %{"id" => user_id}) do
    follows = Social.list_follows(user_id)
    render(conn, "index.json", follows: follows)
  end

  def create(conn, %{"id" => user_id}) do
    user = conn.assigns.current_user

    with {:ok, %Follow{} = follow} <- Social.create_follow(user, user_id) do
      conn
      |> put_status(:created)
      |> render("show.json", follow: follow)
    end
  end

  def delete(conn, %{"id" => user_id}) do
    user = conn.assigns.current_user

    with {:ok, %Follow{}} <- Social.delete_follow(user, user_id) do
      send_resp(conn, :no_content, "")
    end
  end
end
