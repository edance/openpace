defmodule SqueezeWeb.PaymentMethodController do
  use SqueezeWeb, :controller

  alias Squeeze.Billing
  alias Squeeze.Billing.PaymentMethod

  def new(conn, _params) do
    changeset = Billing.change_payment_method(%PaymentMethod{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"payment_method" => payment_method_params}) do
    user = conn.assigns.current_user
    case Billing.create_payment_method(user, payment_method_params) do
      {:ok, _payment_method} ->
        conn
        |> put_flash(:info, "Payment method created successfully.")
        |> redirect(to: billing_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    payment_method = Billing.get_payment_method!(user, id)
    {:ok, _payment_method} = Billing.delete_payment_method(payment_method)

    conn
    |> put_flash(:info, "Payment method deleted successfully.")
    |> redirect(to: billing_path(conn, :index))
  end
end
