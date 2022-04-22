defmodule SqueezeWeb.ActivityController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, params, current_user) do
    page = params |> Map.get("page", "1") |> String.to_integer()
    activities = Dashboard.recent_activities(current_user, page)
    render(conn, "index.html", activities: activities, page: page)
  end

  def mark_complete(conn, %{"activity_id" => id}, user) do
    activity = Dashboard.get_activity!(user, id)

    case Dashboard.update_activity(activity, %{"complete" => true}) do
      {:ok, activity} ->
        conn
        |> put_flash(:info, "Activity completed!")
        |> redirect(to: Routes.activity_path(conn, :show, activity))

      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:info, "Could not mark activity as completed.")
        |> redirect(to: Routes.activity_path(conn, :show, activity))
    end
  end
end
