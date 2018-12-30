defmodule SqueezeWeb.AuthControllerTest do
  use SqueezeWeb.ConnCase
  import Mox

  alias Squeeze.Guardian.Plug
  alias Strava.DetailedAthlete

  # This makes us check whether our mocks have been properly called at the end
  # of each test.
  setup :verify_on_exit!

  test "renders login page", %{conn: conn} do
    conn = get(conn, auth_path(conn, :login))
    assert html_response(conn, 200) =~ ~r/Welcome/
  end

  test "request with strava redirects to strava url", %{conn: conn} do
    Squeeze.Strava.MockAuth
    |> expect(:authorize_url!, fn(_) -> "https://www.strava.com" end)

    conn = get(conn, auth_path(conn, :request, "strava"))
    assert redirected_to(conn) =~ ~r/https:\/\/www.strava.com/
  end

  test "logs out user on delete", %{conn: conn} do
    conn = delete conn, auth_path(conn, :delete)
    user = Plug.current_resource(conn)
    assert user == nil
  end

  describe "#callback" do
    test "with valid code creates a user and redirects", %{conn: conn} do
      Squeeze.Strava.MockAuth
      |> expect(:get_token!, fn(_) ->
        %{token: %{access_token: "access_token", refresh_token: "refresh_token"}}
      end)

      Squeeze.Strava.MockAuth
      |> expect(:get_athlete!, fn(_) ->
        %DetailedAthlete{firstname: "Evan", lastname: "Dancer", id: 12, profile: ""}
      end)

      conn = conn
      |> get(auth_path(conn, :callback, "strava", code: "1234"))

      assert redirected_to(conn) == dashboard_path(conn, :index)
    end

    test "with an invalid user redirects to home", %{conn: conn} do
      Squeeze.Strava.MockAuth
      |> expect(:get_token!, fn(_) ->
        %{token: %{access_token: "access_token", refresh_token: "refresh_token"}}
      end)

      Squeeze.Strava.MockAuth
      |> expect(:get_athlete!, fn(_) ->
        %DetailedAthlete{email: "evan", id: 12}
      end)

      conn = conn
      |> post(auth_path(conn, :callback, "strava", code: "1234"))

      assert redirected_to(conn) == page_path(conn, :index)
    end
  end
end
