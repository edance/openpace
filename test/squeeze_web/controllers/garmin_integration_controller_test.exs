defmodule SqueezeWeb.GarminIntegrationControllerTest do
  use SqueezeWeb.ConnCase
  import Mox

  alias Squeeze.Garmin.AuthMock

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "request/2" do
    test "redirects to Garmin authorization URL", %{conn: conn} do
      token_params = %{
        "oauth_token" => "test_token",
        "oauth_token_secret" => "test_secret"
      }

      expect(Squeeze.Garmin.AuthMock, :request_token!, fn -> token_params end)

      expect(Squeeze.Garmin.AuthMock, :authorize_url!, fn ^token_params ->
        "https://garmin.com/auth"
      end)

      conn = get(conn, Routes.garmin_integration_path(conn, :request))

      assert redirected_to(conn) =~ "https://garmin.com/auth"
      assert get_session(conn, :garmin_token_secret) == "test_secret"
    end
  end

  describe "callback/2" do
    setup do
      token_params = %{
        "oauth_token" => "callback_token",
        "oauth_token_secret" => "callback_secret"
      }

      user_params = %{"userId" => "12345"}

      {:ok, token_params: token_params, user_params: user_params}
    end

    test "signs in existing user with Garmin credentials", %{
      conn: conn,
      token_params: token_params,
      user_params: user_params
    } do
      user = insert(:user)
      insert(:credential, user: user, provider: "garmin", uid: "12345")

      conn = init_test_session(conn, %{garmin_token_secret: "stored_secret"})

      expect(AuthMock, :get_token!, fn [
                                         verifier: "test_verifier",
                                         token: "test_token",
                                         token_secret: "stored_secret"
                                       ] ->
        token_params
      end)

      expect(AuthMock, :get_user!, fn [token: "callback_token", token_secret: "callback_secret"] ->
        user_params
      end)

      conn =
        get(conn, Routes.garmin_integration_path(conn, :callback), %{
          "oauth_token" => "test_token",
          "oauth_verifier" => "test_verifier"
        })

      assert redirected_to(conn) == Routes.dashboard_path(conn, :index)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Connected to garmin"
    end

    test "creates new user when no matching credentials exist", %{
      conn: conn,
      token_params: token_params,
      user_params: user_params
    } do
      conn = init_test_session(conn, %{garmin_token_secret: "stored_secret"})

      expect(AuthMock, :get_token!, fn [
                                         verifier: "test_verifier",
                                         token: "test_token",
                                         token_secret: "stored_secret"
                                       ] ->
        token_params
      end)

      expect(AuthMock, :get_user!, fn [token: "callback_token", token_secret: "callback_secret"] ->
        user_params
      end)

      conn =
        get(conn, Routes.garmin_integration_path(conn, :callback), %{
          "oauth_token" => "test_token",
          "oauth_verifier" => "test_verifier"
        })

      assert redirected_to(conn) == Routes.dashboard_path(conn, :index)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Connected to garmin"
    end
  end
end
