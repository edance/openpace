defmodule SqueezeWeb.StravaWebhookControllerTest do
  use SqueezeWeb.ConnCase

  @moduledoc false

  import Mox
  import Squeeze.Factory

  alias Squeeze.Accounts
  alias Squeeze.Dashboard
  alias Squeeze.Dashboard.Activity

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

  describe "POST /webhook/strava for delete activity" do
    setup [:setup_account, :setup_mocks]

    test "deletes activity if not found on strava", %{conn: conn, activity: activity, credential: credential} do
      Squeeze.Strava.MockActivities
      |> expect(:get_activity_by_id, fn(_, _) -> {:error, %{status: 404}} end)

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

    test "does not delete if found on strava", %{conn: conn, activity: activity, credential: credential} do
      Squeeze.Strava.MockActivities
      |> expect(:get_activity_by_id, fn(_, id) -> {:ok, build(:detailed_activity, id: id)} end)

      params = %{
        "aspect_type" => "delete",
        "object_type" => "activity",
        "object_id" => activity.external_id,
        "owner_id" => credential.uid
      }
      conn = post(conn, "/webhook/strava", params)
      assert json_response(conn, 200) == %{}
      {:ok, %Activity{}} = Dashboard.fetch_activity_by_external_id(credential.user, activity.external_id)
    end
  end

  describe "POST /webhook/strava" do
    setup [:setup_account, :setup_mocks]

    test "returns 200 and empty response", %{conn: conn} do
      conn = post(conn, "/webhook/strava")
      assert json_response(conn, 200) == %{}
    end

    test "user creates an activity on strava", %{conn: conn, credential: credential} do
      activity = build(:activity)
      Squeeze.Strava.MockActivities
      |> expect(:get_activity_by_id, fn(_, id) -> {:ok, build(:detailed_activity, id: id)} end)

      params = %{
        "aspect_type" => "create",
        "object_type" => "activity",
        "object_id" => activity.external_id,
        "owner_id" => credential.uid
      }
      conn = post(conn, "/webhook/strava", params)
      assert json_response(conn, 200) == %{}
      assert %Activity{} = Dashboard.get_activity_by_external_id!(credential.user, activity.external_id)
    end

    test "user updates an activity on strava", %{conn: conn, credential: credential, activity: activity} do

      Squeeze.Strava.MockActivities
      |> expect(:get_activity_by_id, fn(_, id) -> {:ok, build(:detailed_activity, id: id)} end)

      params = %{
        "aspect_type" => "update",
        "object_type" => "activity",
        "object_id" => activity.external_id,
        "owner_id" => credential.uid
      }
      conn = post(conn, "/webhook/strava", params)
      assert json_response(conn, 200) == %{}
      assert %Activity{} = Dashboard.get_activity_by_external_id!(credential.user, activity.external_id)
      assert length(Dashboard.recent_activities(credential.user)) == 1
    end

    test "user deactivates account on strava", %{conn: conn, credential: credential} do
      params = %{
        "updates" => %{"authorized" => "false"},
        "aspect_type" => "delete",
        "object_type" => "athlete",
        "object_id" => credential.uid,
        "owner_id" => credential.uid
      }
      conn = post(conn, "/webhook/strava", params)
      assert json_response(conn, 200) == %{}
      assert Accounts.get_credential("strava", credential.uid) == nil
    end
  end

  defp setup_account(_) do
    credential = insert(:credential)
    activity = insert(:activity, user: credential.user)

    {:ok, activity: activity, credential: credential }
  end

  defp setup_mocks(_) do
    Squeeze.Strava.MockClient
    |> expect(:new, 2, fn(_, _) -> %Tesla.Client{} end)

    Squeeze.Strava.MockStreams
    |> expect(:get_activity_streams, fn(_, _, _, _) -> {:ok, %Strava.StreamSet{}} end)
    {:ok, []}
  end
end
