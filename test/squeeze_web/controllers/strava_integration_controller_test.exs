defmodule SqueezeWeb.StravaIntegrationControllerTest do
  use SqueezeWeb.ConnCase

  @moduledoc false

  import Mox
  import Squeeze.Factory

  alias Squeeze.Accounts
  # alias Squeeze.Dashboard
  # alias Squeeze.Dashboard.Activity

  describe "#request" do
    test "redirects to strava auth url", %{conn: conn} do
      Squeeze.Strava.MockAuth
      |> expect(:authorize_url!, fn(_) -> "https://www.strava.com" end)

      conn = get(conn, "/integration/strava")
      assert redirected_to(conn) =~ ~r/https:\/\/www.strava.com/
    end
  end

  describe "#callback" do
    @tag :no_user
    test "creates a user and redirects if no user", %{conn: conn} do
      mock_get_token()
      athlete = build(:detailed_athlete)
      Squeeze.Strava.MockAuth |> expect(:get_athlete!, fn(_) -> athlete end)

      post(conn, "/integration/strava/callback", code: "1234")
      credential = Accounts.get_credential("strava", athlete.id)
      assert credential
      assert credential.user
    end

    test "logs in as different user if credential already exists", %{conn: conn, user: user} do
      mock_get_token()
      athlete = build(:detailed_athlete)
      insert(:credential, provider: "strava", uid: athlete.id)

      Squeeze.Strava.MockAuth |> expect(:get_athlete!, fn(_) -> athlete end)
      conn = post(conn, "/integration/strava/callback", code: "1234")

      assert conn.assigns.current_user.id != user.id
    end

    test "creates a credential for the user already signed in", %{conn: conn, user: user} do
      mock_get_token()
      athlete = build(:detailed_athlete)
      Squeeze.Strava.MockAuth |> expect(:get_athlete!, fn(_) -> athlete end)

      post(conn, "/integration/strava/callback", code: "1234")
      {:ok, credential} = Accounts.fetch_credential_by_provider(user, "strava")
      assert credential.uid == "#{athlete.id}"
    end

    test "with valid code creates a user and redirects", %{conn: conn} do
      setup_successful_mocks()

      conn = post(conn, "/integration/strava/callback", code: "1234")
      assert redirected_to(conn) == overview_path(conn, :index)
    end
  end

  defp mock_get_token do
    Squeeze.Strava.MockAuth
    |> expect(:get_token!, fn(_) ->
      %{token: %{access_token: "access_token", refresh_token: "refresh_token"}}
    end)
  end

  defp setup_successful_mocks do
    mock_get_token()

    Squeeze.Strava.MockAuth |> expect(:get_athlete!, fn(_) -> build(:detailed_athlete) end)
  end
end
