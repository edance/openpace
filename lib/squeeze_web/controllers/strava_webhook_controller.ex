defmodule SqueezeWeb.StravaWebhookController do
  use SqueezeWeb, :controller
  @moduledoc false

  alias Squeeze.Accounts
  alias Squeeze.Activities
  alias Squeeze.Namer.RenamerJob
  alias Squeeze.Strava.{ActivityLoader, Client}

  require Logger

  @strava_activities Application.compile_env(:squeeze, :strava_activities)

  plug :validate_token when action in [:challenge]
  plug :log_event

  action_fallback SqueezeWeb.Api.FallbackController

  # User deletes an activity on strava
  def webhook(conn, %{"aspect_type" => "delete", "object_type" => "activity"} = params) do
    object_id = params["object_id"]

    with {:ok, %{user: user}} <- Accounts.fetch_credential("strava", params["owner_id"]),
         # Check deleted on strava
         {:error, %{status: 404}} <- fetch_strava_activity(user, object_id),
         {:ok, activity} <- Activities.fetch_activity_by_external_id(user, object_id) do
      Activities.delete_activity(activity)
      render(conn, "success.json")
    else
      _ ->
        Logger.warn("Failed to delete record id: #{object_id} user_id: #{params["owner_id"]}")
        render(conn, "success.json")
    end
  end

  # User creates or updates an activity on strava
  def webhook(conn, %{"object_type" => "activity"} = params) do
    Task.start(fn -> process_event(params) end)

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

  def challenge_token do
    Application.get_env(:strava, :webhook_challenge)
  end

  def fetch_strava_activity(user, activity_id) do
    user
    |> Client.new()
    |> @strava_activities.get_activity_by_id(activity_id)
  end

  defp validate_token(conn, _) do
    token = conn.params["hub.verify_token"]

    if token == challenge_token() do
      conn
    else
      conn
      |> render_bad_request()
      |> halt()
    end
  end

  defp process_event(%{"aspect_type" => "create", "object_type" => "activity"} = params) do
    %{"owner_id" => strava_uid, "object_id" => activity_id} = params
    RenamerJob.perform(strava_uid, activity_id)
  end

  defp process_event(_), do: nil

  defp render_bad_request(conn) do
    conn
    |> put_status(:bad_request)
    |> render("400.json")
  end

  defp log_event(conn, _) do
    body = Jason.encode!(conn.params)
    Squeeze.Logger.log_webhook_event(%{provider: "strava", body: body})
    conn
  end
end
