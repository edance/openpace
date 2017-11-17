defmodule SqueezeWeb.ActivityController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard
  alias Squeeze.Dashboard.Activity

  plug :authorize_activity when action in [:edit, :update, :delete]

  def index(conn, _params) do
    activities = Dashboard.list_activities(conn.assigns.current_user)
    render(conn, "index.html", activities: activities)
  end

  def new(conn, _params) do
    changeset = Dashboard.change_activity(%Activity{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"activity" => activity_params}) do
    case Dashboard.create_activity(activity_params) do
      {:ok, activity} ->
        conn
        |> put_flash(:info, "Activity created successfully.")
        |> redirect(to: activity_path(conn, :show, activity))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    activity = Dashboard.get_activity!(id)
    render(conn, "show.html", activity: activity)
  end

  def edit(conn, _params) do
    activity = conn.assigns.activity
    changeset = Dashboard.change_activity(activity)
    render(conn, "edit.html", activity: activity, changeset: changeset)
  end

  def update(conn, %{"activity" => activity_params}) do
    activity = conn.assigns.activity
    case Dashboard.update_activity(activity, activity_params) do
      {:ok, activity} ->
        conn
        |> put_flash(:info, "Activity updated successfully.")
        |> redirect(to: activity_path(conn, :show, activity))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", activity: activity, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    {:ok, _activity} = Dashboard.delete_activity(conn.assigns.activity)

    conn
    |> put_flash(:info, "Activity deleted successfully.")
    |> redirect(to: activity_path(conn, :index))
  end

  defp authorize_activity(conn, _) do
    activity = Dashboard.get_activity!(conn.params["id"])

    if conn.assigns.current_user.id == activity.user_id do
      assign(conn, :activity, activity)
    else
      conn
      |> put_flash(:error, "You can't modify that activity")
      |> redirect(to: activity_path(conn, :index))
      |> halt()
    end
  end
end
