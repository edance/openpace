defmodule Squeeze.ActivityLoaderTest do
  use Squeeze.DataCase

  import Mox
  import Squeeze.Factory

  alias Squeeze.Strava.ActivityLoader
  alias Squeeze.TimeHelper

  describe "update_or_create_activity/2" do
    setup [:build_strava_activity, :setup_mocks, :create_credential]

    test "creates an activity if none exist",
      %{credential: credential, activity: strava_activity} do
      assert {:ok, _} = ActivityLoader.update_or_create_activity(credential, strava_activity.id)
    end

    test "updates activity if matched activity exists",
      %{credential: credential, activity: strava_activity} do
      distance = strava_activity.distance
      user = credential.user
      insert(:activity, user: user, planned_distance: distance, planned_date: TimeHelper.today(user))
      assert {:ok, _} = ActivityLoader.update_or_create_activity(credential, strava_activity.id)
    end
  end

  defp build_strava_activity(_) do
    {:ok, activity: build(:detailed_activity)}
  end

  defp setup_mocks(%{activity: activity}) do
    Squeeze.Strava.MockClient
    |> expect(:new, 2, fn(_, _) -> %Tesla.Client{} end)

    Squeeze.Strava.MockActivities
    |> expect(:get_activity_by_id, fn(_, _) -> {:ok, activity} end)

    Squeeze.Strava.MockStreams
    |> expect(:get_activity_streams, fn(_, _, _, _) -> {:ok, %Strava.StreamSet{}} end)
    {:ok, []}
  end

  defp create_credential(_) do
    credential = insert(:credential)
    {:ok, credential: credential}
  end

  def create_user(_) do
    user = insert(:user)
    {:ok, user: user}
  end
end
