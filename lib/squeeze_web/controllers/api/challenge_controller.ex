defmodule SqueezeWeb.Api.ChallengeController do
  use SqueezeWeb, :controller

  alias Squeeze.Challenges

  action_fallback SqueezeWeb.Api.FallbackController

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _, user) do
    challenges = Challenges.list_challenges(user)

    render(conn, "index.json", %{challenges: challenges})
  end

  def show(conn, %{"id" => id}, user) do
    challenge = Challenges.get_challenge!(user, id)
    render(conn, "show.json", %{challenge: challenge})
  end

  def leaderboard(conn, %{"id" => id}, user) do
    challenge = Challenges.get_challenge!(user, id)
    scores = Challenges.list_scores(challenge)
    render(conn, "leaderboard.json", %{challenge: challenge, scores: scores})
  end

  def create(conn, %{"challenge" => params}, user) do
    with {:ok, challenge} <- Challenges.create_challenge(user, params),
         {:ok, _} <- Challenges.add_user_to_challenge(user, challenge) do
      conn
      |> put_status(:created)
      |> render("challenge.json", %{challenge: challenge})
    end
  end
end
