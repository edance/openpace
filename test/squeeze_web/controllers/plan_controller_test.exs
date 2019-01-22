defmodule SqueezeWeb.PlanControllerTest do
  use SqueezeWeb.ConnCase

  alias Squeeze.TrainingPlans

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  describe "index" do
    setup [:create_plan]

    test "lists all training_plans", %{conn: conn, plan: plan} do
      conn = get conn, plan_path(conn, :index)
      assert html_response(conn, 200) =~ plan.name
    end
  end

  describe "new plan" do
    test "renders form", %{conn: conn} do
      conn = get conn, plan_path(conn, :new)
      assert html_response(conn, 200) =~ "New Plan"
    end
  end

  describe "create plan" do
    test "redirects to show when data is valid", %{conn: conn, user: user} do
      conn = post conn, plan_path(conn, :create), plan: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == plan_path(conn, :show, id)
      assert TrainingPlans.get_plan!(user, id).name == "some name"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, plan_path(conn, :create), plan: @invalid_attrs
      assert html_response(conn, 200) =~ "New Plan"
    end
  end

  describe "edit plan" do
    setup [:create_plan]

    test "renders form for editing chosen plan", %{conn: conn, plan: plan} do
      conn = get conn, plan_path(conn, :edit, plan)
      assert html_response(conn, 200) =~ "Edit Plan"
    end
  end

  describe "update plan" do
    setup [:create_plan]

    test "redirects when data is valid", %{conn: conn, plan: plan, user: user} do
      conn = put conn, plan_path(conn, :update, plan), plan: @update_attrs
      assert redirected_to(conn) == plan_path(conn, :show, plan)
      assert TrainingPlans.get_plan!(user, plan.id).name == "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, plan: plan} do
      conn = put conn, plan_path(conn, :update, plan), plan: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Plan"
    end
  end

  describe "delete plan" do
    setup [:create_plan]

    test "deletes chosen plan", %{conn: conn, plan: plan} do
      conn = delete conn, plan_path(conn, :delete, plan)
      assert redirected_to(conn) == plan_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, plan_path(conn, :show, plan)
      end
    end
  end

  defp create_plan(%{user: user}) do
    plan = insert(:training_plan, user: user)
    {:ok, plan: plan}
  end
end
