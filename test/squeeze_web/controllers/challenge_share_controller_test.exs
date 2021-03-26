defmodule SqueezeWeb.ChallengeShareControllerTest do
  use SqueezeWeb.ConnCase

  @tag :no_user
  describe "#show" do
    test "includes the challenge name", %{conn: conn} do
      challenge = insert(:challenge)
      conn = get(conn, "/invite/#{challenge.slug}")

      assert html_response(conn, 200) =~ challenge.name
    end

    test "includes a button to join challenge", %{conn: conn} do
      challenge = insert(:challenge)
      conn = get(conn, "/invite/#{challenge.slug}")

      assert html_response(conn, 200) =~ "Join Challenge"
    end
  end
end
