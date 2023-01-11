defmodule SqueezeWeb.TrendsLiveTest do
  use SqueezeWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Index" do
    test "all-time trends", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.trends_path(conn, :index))

      assert html =~ "All-Time Trends"
    end

    test "yearly trends", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.trends_path(conn, :show, "2020"))

      assert html =~ "2020 Trends"
    end
  end
end
