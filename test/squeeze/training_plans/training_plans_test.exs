defmodule Squeeze.TrainingPlansTest do
  use Squeeze.DataCase

  alias Squeeze.TrainingPlans
  alias Squeeze.TrainingPlans.Plan

  import Squeeze.Factory

  test "list_training_plans/1 returns user's training_plans" do
    insert_pair(:training_plan)
    plan = insert(:training_plan)
    plans = TrainingPlans.list_plans(plan.user)
    assert length(plans) == 1
    assert List.first(plans).id == plan.id
  end

  describe "get_plan!/2" do
    test "returns the plan with given id" do
      plan = insert(:training_plan)
      user = plan.user
      assert plan.id == TrainingPlans.get_plan!(user, plan.id).id
    end

    test "raises error if plan does not belong to user" do
      plan = insert(:training_plan)
      user = insert(:user)
      assert_raise Ecto.NoResultsError, fn ->
        TrainingPlans.get_plan!(user, plan.id) end
    end
  end

  describe "create_plan/2" do
    test "with valid data creates a plan" do
      user = insert(:user)
      attrs = params_for(:training_plan)
      assert {:ok, %Plan{}} = TrainingPlans.create_plan(user, attrs)
    end

    test "with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = TrainingPlans.create_plan(user, %{})
    end
  end

  describe "update_plan/2" do
    test "with valid data updates the plan" do
      plan = insert(:training_plan)
      attrs = %{name: "name"}
      assert {:ok, plan} = TrainingPlans.update_plan(plan, attrs)
      assert %Plan{} = plan
      assert plan.name == "name"
    end

    test "with invalid data returns error changeset" do
      plan = insert(:training_plan)
      attrs = %{name: nil}
      assert {:error, %Ecto.Changeset{}} = TrainingPlans.update_plan(plan, attrs)
      assert TrainingPlans.get_plan!(plan.user, plan.id).name != nil
    end
  end

  test "delete_plan/1 deletes the plan" do
    plan = insert(:training_plan)
    user = plan.user
    assert {:ok, %Plan{}} = TrainingPlans.delete_plan(plan)
    assert_raise Ecto.NoResultsError, fn -> TrainingPlans.get_plan!(user, plan.id) end
  end

  test "change_plan/1 returns a plan changeset" do
    plan = build(:training_plan)
    assert %Ecto.Changeset{} = TrainingPlans.change_plan(plan)
  end
end
