defmodule SqueezeWeb.PaceController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard
  alias Squeeze.Dashboard.Pace

  def index(conn, _params) do
    paces = Dashboard.list_paces()
    render(conn, "index.html", paces: paces)
  end

  def new(conn, _params) do
    changeset = Dashboard.change_pace(%Pace{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"pace" => pace_params}) do
    case Dashboard.create_pace(pace_params) do
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

  def edit(conn, %{"id" => id}) do
    pace = Dashboard.get_pace!(id)
    changeset = Dashboard.change_pace(pace)
    render(conn, "edit.html", pace: pace, changeset: changeset)
  end

  def update(conn, %{"id" => id, "pace" => pace_params}) do
    pace = Dashboard.get_pace!(id)

    case Dashboard.update_pace(pace, pace_params) do
      {:ok, pace} ->
        conn
        |> put_flash(:info, "Pace updated successfully.")
        |> redirect(to: pace_path(conn, :show, pace))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", pace: pace, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    pace = Dashboard.get_pace!(id)
    {:ok, _pace} = Dashboard.delete_pace(pace)

    conn
    |> put_flash(:info, "Pace deleted successfully.")
    |> redirect(to: pace_path(conn, :index))
  end
end
