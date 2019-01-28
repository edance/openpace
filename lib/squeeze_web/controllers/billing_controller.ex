defmodule SqueezeWeb.BillingController  do
  use SqueezeWeb, :controller

  alias Squeeze.Billing

  def index(conn, _params) do
    user = conn.assigns.current_user
    payment_methods = Billing.list_payment_methods(user)
    render(conn, "index.html", payment_methods: payment_methods)
  end
end
