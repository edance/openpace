defmodule SqueezeWeb.ChallengeController do
  use SqueezeWeb, :controller

  alias Squeeze.Challenges
  alias Squeeze.Challenges.Challenge
  alias Squeeze.Notifications

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _, user) do
    challenges = Challenges.list_current_challenges(user)
    render(conn, "index.html", challenges: challenges)
  end

  def join(conn, %{"id" => slug}, user) do
    challenge = Challenges.get_challenge_by_slug!(slug)

    with {:ok, _} <- Challenges.add_user_to_challenge(user, challenge) do
      Notifications.notify_user_joined(challenge, user)
      redirect(conn, to: Routes.dashboard_path(conn, :index))
    end
  end

  def new(conn, _, _user) do
    changeset = Challenges.change_challenge(%Challenge{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"challenge" => challenge_params}, user) do
    case Challenges.create_challenge(user, challenge_params) do
      {:ok, challenge} ->
        conn
        |> put_flash(:info, "Challenge created successfully.")
        |> redirect(to: Routes.challenge_path(conn, :edit, challenge))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => slug}, _user) do
    challenge = Challenges.get_challenge_by_slug!(slug)
    render(conn, "show.html", %{challenge: challenge})
  end

  def edit(conn, %{"id" => id}, user) do
    challenge = Challenges.get_challenge!(user, id)
    changeset = Challenges.change_challenge(challenge)
    render(conn, "edit.html", challenge: challenge, changeset: changeset)
  end

  def update(conn, %{"id" => id, "challenge" => challenge_params}, user) do
    challenge = Challenges.get_challenge!(user, id)

    case Challenges.update_challenge(challenge, challenge_params) do
      {:ok, challenge} ->
        conn
        |> put_flash(:info, "Challenge updated successfully.")
        |> redirect(to: Routes.challenge_path(conn, :show, challenge))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", challenge: challenge, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    challenge = Challenges.get_challenge!(user, id)
    {:ok, _challenge} = Challenges.delete_challenge(challenge)

    conn
    |> put_flash(:info, "Challenge deleted successfully.")
    |> redirect(to: Routes.challenge_path(conn, :index))
  end
end
