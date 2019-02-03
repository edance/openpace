defmodule SqueezeWeb.BillingController  do
  use SqueezeWeb, :controller

  alias Squeeze.Billing

  def index(conn, _params) do
    user = conn.assigns.current_user
    payment_method = Billing.get_default_payment_method(user)
    render(conn, "index.html", payment_method: payment_method)
  end
end
