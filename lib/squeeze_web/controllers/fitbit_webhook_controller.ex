defmodule SqueezeWeb.FitbitWebhookController do
  use SqueezeWeb, :controller

  @moduledoc """
  Controller to handle the webhooks from Fitbit
  """

  @challenge Application.get_env(:squeeze, Squeeze.OAuth2.Fitbit)[:webhook_challenge]

  def webhook(conn, %{"verify" => verify_token}) do
    if verify_token == @challenge do
      send_resp(conn, 204, "")
    else
      conn
      |> put_status(:not_found)
      |> render("404.json")
    end
  end

  def webhook(conn, _params) do
    render(conn, "success.json")
  end
end
