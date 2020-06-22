defmodule SqueezeWeb.SitemapControllerTest do
  use SqueezeWeb.ConnCase

  describe "#index.xml" do
    test "renders url for the homepage", %{conn: conn} do
      conn = get(conn, sitemap_path(conn, :index))

      assert conn.resp_body =~ "http://www.example.com/"
      assert conn.status == 200
    end
  end
end
