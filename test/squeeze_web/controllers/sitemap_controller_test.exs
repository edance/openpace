defmodule SqueezeWeb.SitemapControllerTest do
  use SqueezeWeb.ConnCase

  describe "#index.xml" do
    test "renders urls for the races", %{conn: conn} do
      race = insert(:race)
      conn = get(conn, sitemap_path(conn, :index))

      assert conn.resp_body =~ race.slug
      assert conn.status == 200
    end
  end
end
