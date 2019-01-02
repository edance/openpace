defmodule Squeeze.ActivityLoaderTest do
  use Squeeze.DataCase

  import Mox
  import Squeeze.Factory

  alias Squeeze.Strava.ActivityLoader
  alias Squeeze.TimeHelper
  alias Strava.DetailedActivity

  describe "update_or_create_activity/2" do
    setup [:setup_mocks, :create_user]

    test "creates an activity if none exist", %{user: user} do
      {:ok, activity} = ActivityLoader.update_or_create_activity(user, 1)
      refute activity.id == nil
    end

    test "updates activity if matched activity exists", %{user: user} do
      existing_activity = insert(:activity, user: user, planned_date: TimeHelper.today(user))
      {:ok, activity} = ActivityLoader.update_or_create_activity(user, 1)
      assert activity.id == existing_activity.id
    end
  end

  describe "get_closest_activity/2" do
    setup [:create_user, :create_activity]

    test "returns the first if only one activity planned for date", %{user: user, activity: activity} do
      {:ok, activity2} = strava_activity()
      assert ActivityLoader.get_closest_activity(user, activity2).id == activity.id
    end

    test "returns the closest activity on that date", %{user: user, activity: activity} do
      create_activity(%{user: user, planned_distance: 6000.0})
      create_activity(%{user: user, planned_distance: 4000.0})
      {:ok, activity2} = strava_activity()
      assert ActivityLoader.get_closest_activity(user, activity2).id == activity.id
    end
  end

  defp setup_mocks(_) do
    Squeeze.Strava.MockClient
    |> expect(:new, fn(_, _) -> %Tesla.Client{} end)

    Squeeze.Strava.MockActivities
    |> expect(:get_activity_by_id, fn(_, _) -> strava_activity() end)
    {:ok, []}
  end

  defp create_user(_) do
    credential = insert(:credential)
    user = insert(:user, %{credential: credential})
    {:ok, user: user}
  end

  defp create_activity(%{user: user} = attrs) do
    distance = attrs[:planned_distance] || 5000.0
    activity = insert(:activity, user: user, planned_distance: distance, planned_date: TimeHelper.today(user))
    {:ok, activity: activity}
  end

  defp strava_activity do
    activity = %DetailedActivity{
      name: "Morning Run",
      distance: 5000.0,
      moving_time: 1_200, # 20 minutes
      start_date: Timex.now(),
      id: 1,
      map: %{summary_polyline: "ABCDEF"},
      type: "Run"
    }
    {:ok, activity}
  end
end
