defmodule SqueezeWeb.Api.ChallengeController do
  use SqueezeWeb, :controller

  alias Squeeze.Challenges

  action_fallback SqueezeWeb.Api.FallbackController

  def index(conn, %{"start_date" => start_date, "end_date" => end_date}) do
    user = conn.assigns.current_user
    with {:ok, start_date} <- parse_date(start_date),
         {:ok, end_date} <- parse_date(end_date) do
      challenges = Challenges.list_challenges(user, start_date, end_date)

      render(conn, "index.json", %{challenges: challenges})
    end
  end

  def index(conn, _) do
    user = conn.assigns.current_user
    challenges = Challenges.list_current_challenges(user)

    render(conn, "index.json", %{challenges: challenges})
  end

  def show(conn, %{"id" => slug}) do
    challenge = Challenges.get_challenge_by_slug!(slug)
    render(conn, "show.json", %{challenge: challenge})
  end

  def status(conn, %{"id" => slug}) do
    user = conn.assigns.current_user
    challenge = Challenges.get_challenge_by_slug!(slug)
    joined = Challenges.in_challenge?(user, challenge)

    render(conn, "status.json", %{joined: joined})
  end

  def join(conn, %{"id" => slug}) do
    user = conn.assigns.current_user
    challenge = Challenges.get_challenge_by_slug!(slug)
    with {:ok, _} <- Challenges.add_user_to_challenge(user, challenge) do
      send_resp(conn, :no_content, "")
    end
  end

  def leaderboard(conn, %{"id" => slug}) do
    challenge = Challenges.get_challenge_by_slug!(slug)
    scores = Challenges.list_scores(challenge)
    render(conn, "leaderboard.json", %{challenge: challenge, scores: scores})
  end

  def create(conn, %{"challenge" => params}) do
    user = conn.assigns.current_user
    with {:ok, challenge} <- Challenges.create_challenge(user, params),
         {:ok, _} <- Challenges.add_user_to_challenge(user, challenge) do

      challenge = Challenges.get_challenge_by_slug!(challenge.slug)

      conn
      |> put_status(:created)
      |> render("challenge.json", %{challenge: challenge})
    end
  end

  defp parse_date(date) do
    Timex.parse(date, "{YYYY}-{0M}-{0D}")
  end
end
