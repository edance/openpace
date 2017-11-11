defmodule SqueezeWeb.GoalController do
  use SqueezeWeb, :controller

  alias Squeeze.Dashboard
  alias Squeeze.Dashboard.Goal

  plug :authorize_goal when action in [:edit, :update, :delete]

  def index(conn, _params) do
    goals = Dashboard.list_goals(conn.assigns.current_user)
    render(conn, "index.html", goals: goals)
  end

  def new(conn, _params) do
    changeset = Dashboard.change_goal(%Goal{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"goal" => goal_params}) do
    user = conn.assigns.current_user
    case Dashboard.create_goal(user, goal_params) do
      {:ok, goal} ->
        conn
        |> put_flash(:info, "Goal created successfully.")
        |> redirect(to: goal_path(conn, :show, goal))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    goal = Dashboard.get_goal!(id)
    render(conn, "show.html", goal: goal)
  end

  def edit(conn, _params) do
    goal = conn.assigns.goal
    changeset = Dashboard.change_goal(goal)
    render(conn, "edit.html", goal: goal, changeset: changeset)
  end

  def update(conn, %{"goal" => goal_params}) do
    goal = conn.assigns.goal

    case Dashboard.update_goal(goal, goal_params) do
      {:ok, goal} ->
        conn
        |> put_flash(:info, "Goal updated successfully.")
        |> redirect(to: goal_path(conn, :show, goal))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", goal: goal, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    {:ok, _goal} = Dashboard.delete_goal(conn.assigns.goal)

    conn
    |> put_flash(:info, "Goal deleted successfully.")
    |> redirect(to: goal_path(conn, :index))
  end

  defp authorize_goal(conn, _) do
    goal = Dashboard.get_goal!(conn.params["id"])

    if conn.assigns.current_user.id == goal.user_id do
      assign(conn, :goal, goal)
    else
      conn
      |> put_flash(:error, "You can't modify that goal")
      |> redirect(to: goal_path(conn, :index))
      |> halt()
    end
  end
end
