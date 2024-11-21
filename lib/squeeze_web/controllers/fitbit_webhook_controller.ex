defmodule SqueezeWeb.FitbitWebhookController do
  use SqueezeWeb, :controller
  @moduledoc false

  alias Squeeze.Accounts
  alias Squeeze.Fitbit.ActivityLoader
  alias Squeeze.Fitbit.Client
  alias Squeeze.Logger

  plug :log_webhook_event

  def webhook(conn, %{"verify" => verify_token}) do
    if verify_token == challenge() do
      send_resp(conn, 204, "")
    else
      conn
      |> put_status(:not_found)
      |> render("404.json")
    end
  end

  @doc """
  %{
    "_json" => [
      %{
        "collectionType" => "activities",
        "date" => "2019-02-17",
        "ownerId" => "4V79Z9",
        "ownerType" => "user",
        "subscriptionId" => "1"
      }
    ]
  }
  """
  def webhook(conn, %{"_json" => events}) do
    Task.start(fn -> process_events(events) end)
    render(conn, "success.json")
  end

  def webhook(conn, _), do: render(conn, "success.json")

  defp process_events(events) do
    Enum.each(events, &process_event(&1))
  end

  defp process_event(event) do
    credential = Accounts.get_credential("fitbit", event["ownerId"])
    client = Client.new(credential)
    {:ok, response} = Client.get_daily_activity_summary(client, event["date"])

    response.body["activities"]
    |> Enum.each(&create_activity(credential, &1))
  end

  defp create_activity(credential, activity) do
    ActivityLoader.update_or_create_activity(credential, activity)
  end

  defp log_webhook_event(conn, _) do
    body = Jason.encode!(conn.params)
    Logger.log_webhook_event(%{provider: "fitbit", body: body})
    conn
  end

  defp challenge do
    Application.get_env(:squeeze, Squeeze.OAuth2.Fitbit)[:webhook_challenge]
  end
end
