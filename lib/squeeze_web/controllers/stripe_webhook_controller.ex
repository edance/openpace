defmodule SqueezeWeb.StripeWebhookController do
  use SqueezeWeb, :controller

  @moduledoc """
  Controller to handle the webhooks from Stripe
  """

  alias Plug.Conn
  alias Stripe.Webhook

  @secret Application.get_env(:stripity_stripe, :webhook_secret)

  def webhook(conn, _params) do
    payload = conn.assigns.raw_body
    [signature | _] = Conn.get_req_header(conn, "stripe-signature")
    case Webhook.construct_event(payload, signature, @secret) do
      {:ok, %Stripe.Event{} = _event} ->
        render(conn, "success.json")
      {:error, _reason} ->
        render(conn, "success.json")
    end

    render(conn, "success.json")
  end
end
