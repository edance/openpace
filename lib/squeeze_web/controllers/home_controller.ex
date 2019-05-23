defmodule SqueezeWeb.HomeController do
  use SqueezeWeb, :controller

  alias Squeeze.MailingList
  alias Squeeze.MailingList.Subscription

  plug :redirect_registered_user

  def index(conn, _params) do
    changeset = MailingList.change_subscription(%Subscription{})
    render(conn, "index.html", changeset: changeset)
  end

  def subscribe(conn, %{"subscription" => subscription_params}) do
    attrs = Map.merge(subscription_params, %{"type" => "homepage"})
    case MailingList.create_subscription(attrs) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Thanks for signing up!")
        |> redirect(to: home_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Invalid email address")
        |> render("index.html", changeset: changeset)
    end
  end

  defp redirect_registered_user(conn, _) do
    user = conn.assigns.current_user
    if user.registered do
      conn
      |> redirect(to: dashboard_path(conn, :index))
      |> halt()
    else
      conn
    end
  end
end
