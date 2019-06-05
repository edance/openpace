defmodule SqueezeWeb.BillingController  do
  use SqueezeWeb, :controller

  alias Squeeze.Billing

  def index(conn, _params) do
    user = conn.assigns.current_user
    plan = Billing.get_default_plan()
    invoices = Billing.list_invoices(user)
    payment_method = Billing.get_default_payment_method(user)
    render(conn, "index.html",
      invoices: invoices, payment_method: payment_method, plan: plan)
  end

  def cancel(conn, _params) do
    user = conn.assigns.current_user
    Billing.cancel_subscription(user)
    conn
    |> put_flash(:info, "Your membership has been canceled")
    |> redirect(to: Routes.billing_path(conn, :index))
  end
end
