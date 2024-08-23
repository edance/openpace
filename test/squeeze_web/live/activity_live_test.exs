defmodule SqueezeWeb.ActivityLiveTest do
  use SqueezeWeb.ConnCase

  import Phoenix.LiveViewTest
  import Squeeze.Factory

  defp create_activity(%{user: user}) do
    activity = insert(:activity, user: user)
    %{activity: activity}
  end

  describe "Index" do
    setup [:create_activity]

    test "lists all activities", %{conn: conn, activity: activity} do
      {:ok, _index_live, html} = live(conn, Routes.activity_index_path(conn, :index))

      assert html =~ activity.name
    end
  end
end
