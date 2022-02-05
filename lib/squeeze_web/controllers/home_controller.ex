defmodule SqueezeWeb.HomeController do
  use SqueezeWeb, :controller

  alias Squeeze.MailingList
  alias Squeeze.MailingList.Subscription

  plug :redirect_registered_user

  def index(conn, _params) do
    changeset = MailingList.change_subscription(%Subscription{})
    render(conn, "index.html", changeset: changeset)
  end

  def namer(conn, _params) do
    render(conn, "namer.html")
  end

  def subscribe(conn, %{"subscription" => subscription_params}) do
    attrs = Map.merge(subscription_params, %{"type" => "homepage"})
    case MailingList.create_subscription(attrs) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Thanks for signing up!")
        |> redirect(to: Routes.home_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Invalid email address")
        |> render("index.html", changeset: changeset)
    end
  end

  defp redirect_registered_user(conn, _) do
    case conn.assigns[:current_user] do
      nil -> conn
      _ ->
        conn
        |> redirect(to: Routes.dashboard_path(conn, :index))
        |> halt()
    end
  end
end
