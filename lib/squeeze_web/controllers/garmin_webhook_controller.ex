defmodule SqueezeWeb.GarminWebhookController do
  use SqueezeWeb, :controller

  @moduledoc """
  Controller to handle the pings from Garmin
  """

  alias Squeeze.Accounts
  alias Squeeze.Garmin.ActivityLoader
  alias Squeeze.Logger

  plug :log_webhook_event

  def webhook(conn, %{"activities" => activities}) do
    activities
    |> Enum.each(&create_activity/1)

    render(conn, "success.json")
  end
  def webhook(conn, _), do: render(conn, "success.json")

  defp create_activity(activity) do
    Task.start(fn ->
      credential = Accounts.get_credential("garmin", activity["userId"])
      ActivityLoader.update_or_create_activity(credential, activity)
    end)
  end

  defp log_webhook_event(conn, _) do
    body = Jason.encode!(conn.params)
    Logger.log_webhook_event(%{provider: "garmin", body: body})
    conn
  end
end
