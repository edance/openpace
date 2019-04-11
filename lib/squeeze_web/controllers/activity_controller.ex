defmodule SqueezeWeb.ActivityController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard
  alias Squeeze.Dashboard.Activity

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _, current_user) do
    activities = Dashboard.recent_activities(current_user)
    render(conn, "index.html", activities: activities)
  end

  def new(conn, _, _user) do
    changeset = Dashboard.change_activity(%Activity{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"activity" => activity_params}, user) do
    case Dashboard.create_activity(user, activity_params) do
      {:ok, activity} ->
        conn
        |> put_flash(:info, "Activity created successfully.")
        |> redirect(to: activity_path(conn, :show, activity))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    activity = Dashboard.get_activity!(user, id)
    render(conn, "show.html",
      activity: activity,
      altitude: [],
      coordinates: [],
      distance: [],
      heartrate: [],
      splits: [],
      velocity: []
    )
  end

  def edit(conn, %{"id" => id}, user) do
    activity = Dashboard.get_activity!(user, id)
    changeset = Dashboard.change_activity(activity)
    render(conn, "edit.html", activity: activity, changeset: changeset)
  end

  def update(conn, %{"id" => id, "activity" => activity_params}, user) do
    activity = Dashboard.get_activity!(user, id)

    case Dashboard.update_activity(activity, activity_params) do
      {:ok, activity} ->
        conn
        |> put_flash(:info, "Activity updated successfully.")
        |> redirect(to: activity_path(conn, :show, activity))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", activity: activity, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    activity = Dashboard.get_activity!(user, id)
    {:ok, _activity} = Dashboard.delete_activity(activity)

    conn
    |> put_flash(:info, "Activity deleted successfully.")
    |> redirect(to: activity_path(conn, :index))
  end
end
