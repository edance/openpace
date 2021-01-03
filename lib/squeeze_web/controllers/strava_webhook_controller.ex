defmodule SqueezeWeb.StravaWebhookController do
  use SqueezeWeb, :controller

  @moduledoc """
  Controller to handle the webhooks from Strava
  """

  alias Squeeze.Accounts
  alias Squeeze.Dashboard
  alias Squeeze.Logger
  alias Squeeze.Strava.ActivityLoader

  @challenge_token Application.get_env(:strava, :webhook_challenge)

  plug :validate_token when action in [:challenge]
  plug :log_event

  action_fallback SqueezeWeb.Api.FallbackController

  # User deletes an activity on strava
  def webhook(conn, %{"aspect_type" => "delete", "object_type" => "activity"} = params) do
    with {:ok, credential} <- Accounts.fetch_credential("strava", params["owner_id"]) do
      activity = Dashboard.get_activity_by_external_id!(credential.user, params["object_id"])
      Dashboard.delete_activity(activity)
      render(conn, "success.json")
    end
  end

  # User creates or updates an activity on strava
  def webhook(conn, %{"object_type" => "activity"} = params) do
    with {:ok, credential} <- Accounts.fetch_credential("strava", params["owner_id"]),
         {:ok, _} <- ActivityLoader.update_or_create_activity(credential, params["object_id"]) do
      render(conn, "success.json")
    end
  end

  # User deactivates the strava <-> openpace connection
  def webhook(conn, %{"updates" => %{"authorized" => "false"}, "owner_id" => id}) do
    with {:ok, credential} <- Accounts.fetch_credential("strava", id),
         {:ok, _} <- Accounts.delete_credential(credential) do
      render(conn, "success.json")
    end
  end

  def webhook(conn, _), do: render(conn, "success.json")

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

  defp log_event(conn, _)  do
    body = Jason.encode!(conn.params)
    Logger.log_webhook_event(%{provider: "strava", body: body})
    conn
  end
end
