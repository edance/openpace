defmodule SqueezeWeb.PaceController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard
  alias Squeeze.Dashboard.Pace

  plug :authorize_pace when action in [:edit, :update, :delete]

  def index(conn, _params) do
    paces = Dashboard.list_paces(conn.assigns.current_user)
    render(conn, "index.html", paces: paces)
  end

  def new(conn, _params) do
    changeset = Dashboard.change_pace(%Pace{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"pace" => pace_params}) do
    user = conn.assigns.current_user
    case Dashboard.create_pace(user, pace_params) do
      {:ok, pace} ->
        conn
        |> put_flash(:info, "Pace created successfully.")
        |> redirect(to: pace_path(conn, :show, pace))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    pace = Dashboard.get_pace!(id)
    render(conn, "show.html", pace: pace)
  end

  def edit(conn, _pace) do
    pace = conn.assigns.pace
    changeset = Dashboard.change_pace(pace)
    render(conn, "edit.html", pace: pace, changeset: changeset)
  end

  def update(conn, %{"pace" => pace_params}) do
    pace = conn.assigns.pace

    case Dashboard.update_pace(pace, pace_params) do
      {:ok, pace} ->
        conn
        |> put_flash(:info, "Pace updated successfully.")
        |> redirect(to: pace_path(conn, :show, pace))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", pace: pace, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    {:ok, _pace} = Dashboard.delete_pace(conn.assigns.pace)

    conn
    |> put_flash(:info, "Pace deleted successfully.")
    |> redirect(to: pace_path(conn, :index))
  end

  defp authorize_pace(conn, _) do
    pace = Dashboard.get_pace!(conn.params["id"])

    if conn.assigns.current_user.id == pace.user_id do
      assign(conn, :pace, pace)
    else
      conn
      |> put_flash(:error, "You can't modify that pace")
      |> redirect(to: pace_path(conn, :index))
      |> halt()
    end
  end
end
