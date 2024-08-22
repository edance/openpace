defmodule SqueezeWeb.BillingController do
  use SqueezeWeb, :controller
  @moduledoc false

  alias Squeeze.Billing

  def portal(conn, _params) do
    user = conn.assigns.current_user

    with {:ok, user} <- Billing.find_or_create_external_customer(user),
         {:ok, session} <- create_stripe_portal(conn, user) do
      redirect(conn, external: session.url)
    else
      _error ->
        conn
        |> put_flash(:error, "There was an error with checkout")
        |> redirect(to: Routes.dashboard_path(conn, :index))
    end
  end

  def checkout(conn, _params) do
    user = conn.assigns.current_user

    with {:ok, user} <- Billing.find_or_create_external_customer(user),
         {:ok, session} <- create_stripe_session(conn, user) do
      redirect(conn, external: session.url)
    else
      _error ->
        conn
        |> put_flash(:error, "There was an error with checkout")
        |> redirect(to: Routes.dashboard_path(conn, :index))
    end
  end

  defp create_stripe_session(conn, user) do
    opts = %{
      customer: user.customer_id,
      mode: "subscription",
      line_items: line_items("v1"),
      subscription_data: %{
        trial_period_days: 30
      },
      success_url: Routes.dashboard_url(conn, :index),
      cancel_url: Routes.dashboard_url(conn, :index)
    }

    Stripe.Session.create(opts)
  end

  defp create_stripe_portal(conn, user) do
    opts = %{
      customer: user.customer_id,
      return_url: Routes.dashboard_url(conn, :index)
    }

    Stripe.BillingPortal.Session.create(opts)
  end

  defp line_items(pricing_version) do
    stripe_price = stripe_price(pricing_version)

    [%{quantity: 1, price: stripe_price.id}]
  end

  defp stripe_price(pricing_version) do
    opts = %{
      lookup_keys: [pricing_version],
      expand: ["data.product"]
    }

    case Stripe.Price.list(opts) do
      {:ok, list} -> List.first(list.data)
      _ -> nil
    end
  end
end
