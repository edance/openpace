defmodule Squeeze.DashboardTest do
  use Squeeze.DataCase

  alias Squeeze.Dashboard

  import Squeeze.Factory

  describe "events" do
    test "list_events/2 includes only the users events" do
      event1 = insert(:event)
      event2 = insert(:event, date: event1.date)
      range = Date.range(event1.date, Date.add(event1.date, 1))
      events = Dashboard.list_events(event1.user, range)
      assert events |> Enum.map(&(&1.id)) |> Enum.member?(event1.id)
      refute events |> Enum.map(&(&1.id)) |> Enum.member?(event2.id)
    end

    test "list_events/2 returns only the events in the range" do
      user = insert(:user)
      event1 = insert(:event, user: user)
      event2 = insert(:event, user: user, date: Date.add(event1.date, 2))
      range = Date.range(event1.date, Date.add(event1.date, 1))
      events = Dashboard.list_events(user, range)
      assert events |> Enum.map(&(&1.id)) |> Enum.member?(event1.id)
      refute events |> Enum.map(&(&1.id)) |> Enum.member?(event2.id)
    end

    test "list_past_events/1 returns only the users events in the past" do
      old_event = insert(:event, date: Date.utc_today)
      future_event = insert(:event, user: old_event.user)
      events = Dashboard.list_past_events(future_event.user)
      assert events |> Enum.map(&(&1.id)) |> Enum.member?(old_event.id)
      refute events |> Enum.map(&(&1.id)) |> Enum.member?(future_event.id)
    end
  end
end
