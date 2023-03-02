defmodule SqueezeWeb.Dashboard.OverviewLiveTest do
  use SqueezeWeb.ConnCase

  import Phoenix.LiveViewTest
  import Squeeze.Factory

  alias Faker.Date

  describe "Index" do
    test "lists upcoming race goals", %{conn: conn, user: user} do
      [race_goal, _] = insert_pair(:race_goal, user: user, race_date: Date.forward(100))

      {:ok, _index_live, html} = live(conn, Routes.overview_path(conn, :index))

      assert html =~ html_escape(race_goal.race_name)
    end
  end
end
