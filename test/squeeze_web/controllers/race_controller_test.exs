defmodule SqueezeWeb.RaceControllerTest do
  use SqueezeWeb.ConnCase

  describe "#show" do
    test "renders the race", %{conn: conn} do
      race = insert(:race)
      conn = get(conn, race.slug)

      assert html_response(conn, 200) =~ race.name
    end
  end
end
