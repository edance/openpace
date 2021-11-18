defmodule SqueezeWeb.ChallengeController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts
  alias Squeeze.Challenges
  alias Squeeze.Challenges.Challenge
  alias Squeeze.Notifications
  alias Squeeze.Strava.Client
  alias Squeeze.TimeHelper

  @strava_segments Application.get_env(:squeeze, :strava_segments)

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _, user) do
    date = TimeHelper.today(user) |> Timex.shift(days: -3)
    challenges = Challenges.list_challenges(user, ends_after: date)
    podium_finishes = Challenges.podium_finishes(user)
    render(conn, "index.html", challenges: challenges, podium_finishes: podium_finishes)
  end

  def join(conn, %{"id" => slug}, user) do
    challenge = Challenges.get_challenge_by_slug!(slug)

    with {:ok, _} <- Challenges.add_user_to_challenge(user, challenge) do
      Notifications.notify_user_joined(challenge, user)
      redirect(conn, to: Routes.challenge_path(conn, :show, challenge.slug))
    end
  end

  def new(conn, %{"challenge_type" => "segment"}, user) do
    with {:ok, credential} <- Accounts.fetch_credential_by_provider(user, "strava"),
         {:ok, segments} <- get_strava_segments(credential) do
      changeset = Challenges.change_challenge(%Challenge{challenge_type: :segment, activity_type: :run})
      render(conn, "new.html", changeset: changeset, challenge_type: :segment, segments: segments)
    end
  end
  def new(conn, %{"challenge_type" => type}, _user) do
    type = String.to_atom(type)
    changeset = Challenges.change_challenge(%Challenge{challenge_type: type, activity_type: :run})
    render(conn, "new.html", changeset: changeset, challenge_type: type)
  end

  def new(conn, _, _user) do
    redirect(conn, to: Routes.challenge_path(conn, :index))
  end

  def create(conn, %{"challenge" => params, "challenge_type" => type}, user) do
    type = String.to_atom(type)
    with {:ok, challenge} <- Challenges.create_challenge(user, params),
         {:ok, _} <- Challenges.add_user_to_challenge(user, challenge) do
        conn
        |> put_flash(:info, "Challenge created successfully.")
        |> redirect(to: Routes.challenge_path(conn, :show, challenge.slug))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, challenge_type: type)
    end
  end

  def show(conn, %{"id" => slug}, _user) do
    challenge = Challenges.get_challenge_by_slug!(slug)
    render(conn, "show.html", %{challenge: challenge})
  end

  defp get_strava_segments(credential) do
    opts = [
      per_page: 50,
      page: 1,
    ]
    Client.new(credential)
    |> @strava_segments.get_logged_in_athlete_starred_segments(opts)
  end
end
