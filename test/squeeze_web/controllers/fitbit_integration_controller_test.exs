defmodule SqueezeWeb.FitbitIntegrationControllerTest do
  use SqueezeWeb.ConnCase
  import Mox

  alias Squeeze.Fitbit.AuthMock

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "request/2" do
    test "redirects to Fitbit authorization URL", %{conn: conn} do
      expect(Squeeze.Fitbit.AuthMock, :authorize_url!, fn [scope: _, expires_in: _] ->
        "https://fitbit.com/oauth2/authorize"
      end)

      conn = get(conn, Routes.fitbit_integration_path(conn, :request))

      assert redirected_to(conn) =~ "https://fitbit.com/oauth2/authorize"
    end
  end

  describe "callback/2" do
    setup do
      client = %{access_token: "test_access_token"}

      credential_params = %{
        access_token: "test_access_token",
        refresh_token: "test_refresh_token",
        provider: "fitbit",
        uid: "12345"
      }

      user_data = %{
        "firstName" => "John",
        "lastName" => "Doe",
        "avatar" => "avatar.jpg",
        "gender" => "MALE",
        "dateOfBirth" => "1990-01-01",
        "timezone" => "America/New_York",
        "distanceUnit" => "en_US"
      }

      {:ok, client: client, credential_params: credential_params, user_data: user_data}
    end

    test "signs in existing user with Fitbit credentials", %{
      conn: conn,
      client: client,
      credential_params: credential_params
    } do
      user = insert(:user)
      insert(:credential, user: user, provider: "fitbit", uid: "12345")

      expect(AuthMock, :get_token!, fn [code: "test_code", grant_type: "authorization_code"] ->
        client
      end)

      expect(AuthMock, :get_credential!, fn ^client -> credential_params end)

      conn = get(conn, Routes.fitbit_integration_path(conn, :callback), %{"code" => "test_code"})

      assert redirected_to(conn) == Routes.dashboard_path(conn, :index)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Connected to fitbit"
    end

    test "connects Fitbit to current user", %{
      conn: conn,
      client: client,
      credential_params: credential_params
    } do
      user = insert(:user)
      conn = assign(conn, :current_user, user)

      expect(AuthMock, :get_token!, fn [code: "test_code", grant_type: "authorization_code"] ->
        client
      end)

      expect(AuthMock, :get_credential!, fn ^client -> credential_params end)

      conn = get(conn, Routes.fitbit_integration_path(conn, :callback), %{"code" => "test_code"})

      assert redirected_to(conn) == Routes.dashboard_path(conn, :index)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Connected to fitbit"
    end

    test "creates new user through Fitbit", %{
      conn: conn,
      client: client,
      credential_params: credential_params,
      user_data: user_data
    } do
      expect(AuthMock, :get_token!, fn [code: "test_code", grant_type: "authorization_code"] ->
        client
      end)

      expect(AuthMock, :get_credential!, fn ^client -> credential_params end)

      expect(Squeeze.Fitbit.Client, :new, fn "test_access_token" ->
        %{}
      end)

      expect(Squeeze.Fitbit.Client, :get_logged_in_user, fn %{} ->
        {:ok, user_data}
      end)

      conn = get(conn, Routes.fitbit_integration_path(conn, :callback), %{"code" => "test_code"})

      assert redirected_to(conn) == Routes.dashboard_path(conn, :index)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Connected to fitbit"
    end
  end
end
