defmodule SqueezeWeb.RaceController do
  use SqueezeWeb, :controller
  @moduledoc false

  alias Squeeze.MailingList
  alias Squeeze.MailingList.Subscription
  alias Squeeze.Races

  def show(conn, %{"slug" => slug}) do
    changeset = MailingList.change_subscription(%Subscription{})
    race = Races.get_race!(slug)
    render(conn, "show.html", race: race, changeset: changeset)
  end

  def subscribe(conn, %{"subscription" => subscription_params}) do
    attrs = Map.merge(subscription_params, %{"type" => "race"})

    case MailingList.create_subscription(attrs) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Thanks for subscribing! We'll keep you updated.")
        |> redirect(to: Routes.home_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Invalid email address")
        |> render("index.html", changeset: changeset)
    end
  end
end
