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
  def webhook(conn, %{"_json" => _events}) do
    render(conn, "success.json")
  end

  def webhook(conn, _), do: render(conn, "success.json")
end
