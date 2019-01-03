defmodule Squeeze.ActivityLoaderTest do
  use Squeeze.DataCase

  import Mox
  import Squeeze.Factory

  alias Squeeze.Strava.ActivityLoader
  alias Squeeze.TimeHelper

  describe "update_or_create_activity/2" do
    setup [:build_strava_activity, :setup_mocks, :create_user]

    test "creates an activity if none exist", %{user: user, run_activity: strava_activity} do
      {:ok, activity} = ActivityLoader.update_or_create_activity(user, strava_activity.id)
      refute activity.id == nil
    end

    test "updates activity if matched activity exists",
      %{user: user, run_activity: strava_activity} do
      existing_activity = insert(:activity, user: user, planned_date: TimeHelper.today(user))
      {:ok, activity} = ActivityLoader.update_or_create_activity(user, strava_activity.id)
      assert activity.id == existing_activity.id
    end

    test "does nothing if strava_activity is not a run",
      %{user: user, swim_activity: strava_activity} do
      assert ActivityLoader.update_or_create_activity(user, strava_activity) == {:ok, nil}
    end
  end

  describe "get_closest_activity/2" do
    setup [:create_user, :build_strava_activity, :create_activity]

    test "returns the first if only one activity planned for date",
      %{user: user, run_activity: strava_activity, activity: activity} do
      assert ActivityLoader.get_closest_activity(user, strava_activity).id == activity.id
    end

    test "returns the closest activity on that date", %{user: user, activity: activity, run_activity: strava_activity} do
      create_activity(%{user: user, planned_distance: 6000.0})
      create_activity(%{user: user, planned_distance: 4000.0})
      assert ActivityLoader.get_closest_activity(user, strava_activity).id == activity.id
    end
  end

  defp build_strava_activity(_) do
    {:ok,
     swim_activity: build(:detailed_activity, type: "Swim"),
     run_activity: build(:detailed_activity)}
  end

  defp setup_mocks(%{swim_activity: swim_activity, run_activity: run_activity}) do
    activities = %{swim_activity.id => swim_activity, run_activity.id => run_activity}

    Squeeze.Strava.MockClient
    |> expect(:new, fn(_, _) -> %Tesla.Client{} end)

    Squeeze.Strava.MockActivities
    |> expect(:get_activity_by_id, fn(_, id) -> {:ok, activities[id]} end)
    {:ok, []}
  end

  defp create_user(_) do
    user = insert(:user) |> with_credential()
    {:ok, user: user}
  end

  defp create_activity(%{user: user} = attrs) do
    distance = attrs[:planned_distance] || 5000.0
    activity = insert(:activity, user: user, planned_distance: distance, planned_date: TimeHelper.today(user))
    {:ok, activity: activity}
  end
end
