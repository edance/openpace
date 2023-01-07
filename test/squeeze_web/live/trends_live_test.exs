defmodule SqueezeWeb.TrendsLiveTest do
  use SqueezeWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Index" do
    test "show trends", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.trends_path(conn, :index))

      assert html =~ "Trends"
    end
  end
end
