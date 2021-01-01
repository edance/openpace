defmodule SqueezeWeb.StravaWebhookControllerTest do
  use SqueezeWeb.ConnCase

  @moduledoc false

  import Squeeze.Accounts
  import Squeeze.Dashboard
  import Squeeze.Dashboard.Activity
  import Squeeze.Factory

  describe "GET /webhook/strava" do
    test "returns 400 with no challenge", %{conn: conn} do
      conn = get(conn, "/webhook/strava")
      assert json_response(conn, 400) == %{}
    end

    test "returns 400 with bad challenge", %{conn: conn} do
      conn = get(conn, "/webhook/strava", %{"hub.verify_token" => "test"})
      assert json_response(conn, 400) == %{}
    end

    test "returns 200 with correct challenge", %{conn: conn} do
      challenge = "12345"
      params = %{"hub.challenge" => challenge, "hub.verify_token" => "STRAVA"}
      conn = get(conn, "/webhook/strava", params)
      assert json_response(conn, 200) == %{"hub.challenge" => challenge}
    end
  end

  describe "POST /webhook/strava" do
    setup [:setup_account]

    test "returns 200 and empty response", %{conn: conn} do
      conn = post(conn, "/webhook/strava")
      assert json_response(conn, 200) == %{}
    end

    test "user deletes an activity on strava", %{conn: conn, activity: activity, credential: credential} do
      params = %{
        "aspect_type" => "delete",
        "object_type" => "activity",
        "object_id" => activity.external_id,
        "owner_id" => credential.uid
      }
      conn = post(conn, "/webhook/strava", params)
      assert json_response(conn, 200) == %{}
      assert_raise Ecto.NoResultsError, fn ->
        Dashboard.get_activity_by_external_id!(credential.user, activity.external_id) end
    end

    test "user creates an activity on strava", %{conn: conn, credential: credential} do
      activity = build(:activity)
      params = %{
        "aspect_type" => "create",
        "object_type" => "activity",
        "object_id" => activity.external_id,
        "owner_id" => credential.uid
      }
      conn = post(conn, "/webhook/strava", params)
      assert %Activity{} = Dashboard.get_activity_by_external_id!(credential.user, activity.external_id)
    end

    test "user creates an activity on strava", %{conn: conn, credential: credential, activity: activity} do
      params = %{
        "aspect_type" => "create",
        "object_type" => "activity",
        "object_id" => activity.external_id,
        "owner_id" => credential.uid
      }
      conn = post(conn, "/webhook/strava", params)
      assert %Activity{} = Dashboard.get_activity_by_external_id!(credential.user, activity.external_id)
      assert length(Dashboard.list_activities(credential.user)) == 1
    end

    test "user deactivates account on strava", %{conn: conn, credential: credential} do
      params = %{
        "aspect_type" => "delete",
        "object_type" => "athlete",
        "object_id" => credential.uid,
        "owner_id" => credential.uid
      }
      conn = post(conn, "/webhook/strava", params)
      assert Accounts.get_credential("strava", credential.uid) == nil
    end
  end

  defp setup_account(_) do
    credential = insert(:credential)
    activity = insert(:activity, user: credential.user)

    {:ok, activity: activity, credential: credential }
  end
end
