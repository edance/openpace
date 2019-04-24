defmodule SqueezeWeb.StripeWebhookController do
  use SqueezeWeb, :controller

  @moduledoc """
  Controller to handle the webhooks from Stripe
  """

  alias Plug.Conn
  alias Squeeze.Billing
  alias Squeeze.Logger
  alias Stripe.Webhook

  @secret Application.get_env(:stripity_stripe, :webhook_secret)

  plug :log_webhook_event

  def webhook(conn, _params) do
    payload = conn.assigns[:raw_body]
    signature = get_stripe_signature(conn)
    case construct_event(payload, signature) do
      {:ok, %Stripe.Event{} = event} ->
        Task.start(fn -> process_event(event) end)
        render(conn, "success.json")
      {:error, _reason} ->
        render_bad_request(conn)
    end
  end

  defp process_event(%{type: "invoice." <> _} = event) do
    object = event.data.object
    case Billing.get_user_by_customer_id(object.customer) do
      nil -> {:error}
      user -> Billing.create_or_update_invoice(user, parse_invoice(object))
    end
  end
  defp process_event(%{type: "customer.subscription.created"} = event) do
    Billing.update_subscription_status(event.data.object)
  end
  defp process_event(%{type: "customer.subscription.updated"} = event) do
    Billing.update_subscription_status(event.data.object)
  end
  defp process_event(_), do: nil

  defp get_stripe_signature(conn) do
    case Conn.get_req_header(conn, "stripe-signature") do
      [] -> nil
      [signature | _] -> signature
    end
  end

  defp construct_event(payload, signature) do
    if is_nil(payload) || is_nil(signature) do
      {:error, "invalid event"}
    else
      Webhook.construct_event(payload, signature, @secret)
    end
  end

  defp render_bad_request(conn)  do
    conn
    |> put_status(:bad_request)
    |> render("400.json")
  end

  defp parse_invoice(object) do
    name = object.lines.data |> Enum.map(&Map.get(&1, :description)) |> Enum.join(", ")
    {:ok, due_date} = DateTime.from_unix(object.period_end)
    object
    |> Map.take(~w(amount_due status)a)
    |> Map.merge(%{name: name, provider_id: object.id, due_date: due_date})
  end

  defp log_webhook_event(conn, _) do
    body = Poison.encode!(conn.params)
    Logger.log_webhook_event(%{provider: "stripe", body: body})
    conn
  end
end
