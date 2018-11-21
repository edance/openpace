defmodule SqueezeWeb.StravaWebhookController do
  use SqueezeWeb, :controller

  @moduledoc """
  Controller to handle the webhooks from Strava
  """

  alias Squeeze.Accounts
  alias Strava.Client

  @challenge_token Application.get_env(:strava, :webhook_challenge)

  plug :validate_token when action in [:challenge]

  def webhook(conn, %{"object_type" => "activity"} = params) do
    uid = params["owner_id"]
    activity_id = params["object_id"]
    credential = Accounts.get_credential("strava", uid)
    client = Client.new(credential.access_token,
      refresh_token: credential.refresh_token,
      token_refreshed: &Accounts.update_credential(credential, Map.from_struct(&1.token))
    )
    {:ok, %Strava.DetailedActivity{} = activity} = Strava.Activities.get_activity_by_id(client, activity_id)
    render(conn, "success.json")
  end

  def challenge(conn, %{"hub.challenge" => challenge}) do
    render(conn, "challenge.json", challenge: challenge)
  end

  defp validate_token(conn, _) do
    token = conn.params["hub.verify_token"]
    if token == @challenge_token do
      conn
    else
      conn
      |> render_bad_request()
      |> halt()
    end
  end

  defp render_bad_request(conn)  do
    conn
    |> put_status(:bad_request)
    |> render("400.json")
  end
end
