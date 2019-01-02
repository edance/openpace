defmodule Squeeze.SyncTest do
  use Squeeze.DataCase
  import Mox

  alias Squeeze.Accounts
  alias Squeeze.Dashboard
  alias Squeeze.Sync

  import Squeeze.Factory

  describe "#load_activities/1" do
    test "without credentials returns an empty array" do
      user = build(:guest_user)
      assert Sync.load_activities(user) == {:ok, %{}}
    end

    test "updates sync_at for the user" do
      Squeeze.Strava.MockClient
      |> expect(:new, fn(_, _) -> %Tesla.Client{} end)

      Squeeze.Strava.MockActivities
      |> expect(:get_logged_in_athlete_activities, fn(_, _) -> {:ok, []} end)

      user = insert(:user) |> with_credential()
      Sync.load_activities(user)
      refute Accounts.get_user!(user.id).credential.sync_at == nil
    end

    test "creates activities for the user" do
      Squeeze.Strava.MockClient
      |> expect(:new, fn(_, _) -> %Tesla.Client{} end)

      Squeeze.Strava.MockActivities
      |> expect(:get_logged_in_athlete_activities, fn(_, _) -> {:ok, [strava_activity()]} end)

      user = insert(:user) |> with_credential()
      Sync.load_activities(user)
      activity = user |> Dashboard.recent_activities() |> List.first()
      assert activity.name == strava_activity().name
    end
  end

  defp strava_activity do
    %Strava.SummaryActivity{
      id: 1,
      name: "Morning Run",
      distance: 5000.0,
      moving_time: 5000,
      start_date: DateTime.utc_now(),
      map: %{summary_polyline: "ABCDEF"},
      type: "Run"
    }
  end
end
