defmodule SqueezeWeb.Api.ChallengeController do
  use SqueezeWeb, :controller

  alias Squeeze.Challenges

  action_fallback SqueezeWeb.Api.FallbackController

  def index(conn, _) do
    render(conn, %{})
  end

  def create(conn, %{"challenge" => params}) do
    user = conn.assigns.current_user

    with {:ok, challenge} <- Challenges.create_challenge(user, params) do
      conn
      |> put_status(:created)
      |> render("challenge.json", %{challenge: challenge})
    end
  end

  def update(_, _) do
  end
end
