defmodule SqueezeWeb.HomeController do
  use SqueezeWeb, :controller

  alias Squeeze.MailingList

  plug :redirect_registered_user

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def subscribe(conn, %{"email" => email}) do
    attrs = %{email: email, type: "homepage"}
    case MailingList.create_subscription(attrs) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Thanks for signing up!")
        |> render(conn, "index.html")
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "index.html", changeset: changeset)
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
