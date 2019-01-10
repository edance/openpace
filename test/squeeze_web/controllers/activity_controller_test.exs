defmodule SqueezeWeb.ActivityControllerTest do
  use SqueezeWeb.ConnCase

  import Mox

  test "lists all activities on index", %{conn: conn} do
    conn = get conn, activity_path(conn, :index)
    assert html_response(conn, 200) =~ "Activities"
  end

  @tag :strava_user
  describe "GET show" do
    setup [:setup_mocks]

    test "renders the activity", %{conn: conn, user: user} do
      activity = insert(:activity, user: user)
      conn = get conn, activity_path(conn, :show, activity)
      assert html_response(conn, 200) =~ activity.name
    end
  end

  defp setup_mocks(_) do
    Squeeze.Strava.MockClient
    |> expect(:new, fn(_, _) -> %Tesla.Client{} end)

    distance = %{data: [1, 2, 3]}

    Squeeze.Strava.MockStreams
    |> expect(:get_activity_streams, fn(_, _, _, true) ->
      {:ok, %Strava.StreamSet{distance: distance}} end)

    {:ok, []}
  end
end
