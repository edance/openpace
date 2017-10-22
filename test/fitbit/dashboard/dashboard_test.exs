defmodule Fitbit.DashboardTest do
  use Fitbit.DataCase

  alias Fitbit.Dashboard

  describe "activities" do
    alias Fitbit.Dashboard.Activity

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def activity_fixture(attrs \\ %{}) do
      {:ok, activity} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Dashboard.create_activity()

      activity
    end

    test "list_activities/0 returns all activities" do
      activity = activity_fixture()
      assert Dashboard.list_activities() == [activity]
    end

    test "get_activity!/1 returns the activity with given id" do
      activity = activity_fixture()
      assert Dashboard.get_activity!(activity.id) == activity
    end

    test "create_activity/1 with valid data creates a activity" do
      assert {:ok, %Activity{} = activity} = Dashboard.create_activity(@valid_attrs)
    end

    test "create_activity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dashboard.create_activity(@invalid_attrs)
    end

    test "update_activity/2 with valid data updates the activity" do
      activity = activity_fixture()
      assert {:ok, activity} = Dashboard.update_activity(activity, @update_attrs)
      assert %Activity{} = activity
    end

    test "update_activity/2 with invalid data returns error changeset" do
      activity = activity_fixture()
      assert {:error, %Ecto.Changeset{}} = Dashboard.update_activity(activity, @invalid_attrs)
      assert activity == Dashboard.get_activity!(activity.id)
    end

    test "delete_activity/1 deletes the activity" do
      activity = activity_fixture()
      assert {:ok, %Activity{}} = Dashboard.delete_activity(activity)
      assert_raise Ecto.NoResultsError, fn -> Dashboard.get_activity!(activity.id) end
    end

    test "change_activity/1 returns a activity changeset" do
      activity = activity_fixture()
      assert %Ecto.Changeset{} = Dashboard.change_activity(activity)
    end
  end
end
