defmodule SqueezeWeb.AuthControllerTest do
  use SqueezeWeb.ConnCase
  import Mox

  # This makes us check whether our mocks have been properly called at the end
  # of each test.
  setup :verify_on_exit!

  describe "GET #request" do
    test "with provider google", %{conn: conn} do
      conn = get(conn, auth_path(conn, :request, "google"))
      assert redirected_to(conn) =~ ~r/https:\/\/accounts.google.com/
    end
  end
end
