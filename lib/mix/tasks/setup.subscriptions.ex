defmodule Mix.Tasks.Setup.Subscriptions do
  use Mix.Task

  @moduledoc """
  Creates the required subscriptions (webhooks) for different services to push
  activities and status to squeeze.

  ## Examples

    cmd> mix setup.subscriptions
    Created strava webhook subscription
  """

  alias HTTPoison.Response

  @doc false
  def run(_) do
    Mix.Task.run("app.start")
    create_strava_subscription()
    Mix.shell.info("Created strava webhook subscription")
  end

  defp create_strava_subscription do
    url = "https://www.strava.com/api/v3/push_subscriptions"
    form = [
      client_id: Application.get_env(:strava, :client_id),
      client_secret: Application.get_env(:strava, :client_secret),
      callback_url: "#{System.get_env("HOST_URL")}/webhook/strava",
      verify_token: Application.get_env(:strava, :webhook_challenge)
    ]

    {:ok, %Response{status_code: 201}} = HTTPoison.post(url, {:form, form})
  end
end
