defmodule SqueezeWeb.PlanController do
  use SqueezeWeb, :controller

  alias Squeeze.TrainingPlans
  alias Squeeze.TrainingPlans.Plan

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _, user) do
    plans = TrainingPlans.list_plans(user)
    render(conn, "index.html", training_plans: plans)
  end

  def new(conn, _, _user) do
    changeset = TrainingPlans.change_plan(%Plan{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"plan" => plan_params}, user) do
    case TrainingPlans.create_plan(user, plan_params) do
      {:ok, plan} ->
        conn
        |> put_flash(:info, "Plan created successfully.")
        |> redirect(to: Routes.plan_path(conn, :edit, plan))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    plan = TrainingPlans.get_plan!(user, id)
    render(conn, "show.html", plan: plan)
  end

  def edit(conn, %{"id" => id}, user) do
    plan = TrainingPlans.get_plan!(user, id)
    changeset = TrainingPlans.change_plan(plan)
    render(conn, "edit.html", plan: plan, changeset: changeset)
  end

  def update(conn, %{"id" => id, "plan" => plan_params}, user) do
    plan = TrainingPlans.get_plan!(user, id)

    case TrainingPlans.update_plan(plan, plan_params) do
      {:ok, plan} ->
        conn
        |> put_flash(:info, "Plan updated successfully.")
        |> redirect(to: Routes.plan_path(conn, :show, plan))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", plan: plan, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    plan = TrainingPlans.get_plan!(user, id)
    {:ok, _plan} = TrainingPlans.delete_plan(plan)

    conn
    |> put_flash(:info, "Plan deleted successfully.")
    |> redirect(to: Routes.plan_path(conn, :index))
  end
end
