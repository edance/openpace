defmodule SqueezeWeb.ChallengeController do
  use SqueezeWeb, :controller
  @moduledoc false

  alias Squeeze.Challenges
  alias Squeeze.Notifications

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def join(conn, %{"id" => slug}, user) do
    challenge = Challenges.get_challenge_by_slug!(slug)

    with {:ok, _} <- Challenges.add_user_to_challenge(user, challenge) do
      Notifications.notify_user_joined(challenge, user)
      redirect(conn, to: Routes.challenge_path(conn, :show, challenge.slug))
    end
  end
end
