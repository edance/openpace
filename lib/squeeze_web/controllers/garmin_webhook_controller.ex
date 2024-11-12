defmodule SqueezeWeb.GarminWebhookController do
  use SqueezeWeb, :controller
  @moduledoc false

  alias Squeeze.Logger

  plug :log_webhook_event

  def webhook(conn, _params) do
    render(conn, "success.json")
  end

  defp log_webhook_event(conn, _) do
    body = Jason.encode!(conn.params)
    Logger.log_webhook_event(%{provider: "garmin", body: body})
    conn
  end
end
