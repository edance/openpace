defmodule SqueezeWeb.IntegrationControllerTest do
  use SqueezeWeb.ConnCase
  import Mox

  alias Strava.DetailedAthlete

  # This makes us check whether our mocks have been properly called at the end
  # of each test.
  setup :verify_on_exit!

  describe "GET #request" do
    test "with provider fitbit", %{conn: conn} do
      conn = get(conn, integration_path(conn, :request, "fitbit"))
      assert redirected_to(conn) =~ ~r/https:\/\/www.fitbit.com/
    end

    test "with provider strava", %{conn: conn} do
      Squeeze.Strava.MockAuth
      |> expect(:authorize_url!, fn(_) -> "https://www.strava.com" end)

      conn = get(conn, integration_path(conn, :request, "strava"))
      assert redirected_to(conn) =~ ~r/https:\/\/www.strava.com/
    end
  end

  describe "#callback" do
    test "with valid code creates a user and redirects", %{conn: conn} do
      Squeeze.Strava.MockAuth
      |> expect(:get_token!, fn(_) ->
        %{token: %{access_token: "access_token", refresh_token: "refresh_token"}}
      end)

      Squeeze.Strava.MockAuth
      |> expect(:get_athlete!, fn(_) ->
        %DetailedAthlete{firstname: "Alice", lastname: "Bob", id: 12, profile: ""}
      end)

      conn = conn
      |> get(integration_path(conn, :callback, "strava", code: "1234"))

      assert redirected_to(conn) == dashboard_path(conn, :index)
    end
  end
end
