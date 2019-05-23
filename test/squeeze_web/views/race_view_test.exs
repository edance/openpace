defmodule SqueezeWeb.RaceViewTest do
  use SqueezeWeb.ConnCase, async: true

  alias SqueezeWeb.RaceView

  describe "distance/1" do
    test "with a race in the US" do
      opts = %{race: %{distance: 42_195.0, country: "US"}}
      assert RaceView.distance(opts) == "26.22 mi"
    end

    test "with a race outside the US" do
      opts = %{race: %{distance: 42_195.0, country: "CA"}}
      assert RaceView.distance(opts) == "42.2 km"
    end
  end

  test "start_at/1" do
    {:ok, datetime} = NaiveDateTime.new(2019, 5, 25, 7, 15, 0)
    opts = %{race: %{start_at: datetime, timezone: "America/New_York"}}
    assert RaceView.start_at(opts) =~ ~r/^2019-05-25T07:15:00-0[4-5]:00$/
  end

  test "countdown_timer/1" do
    datetime = Timex.now
    |> Timex.shift(days: 2, hours: 3, minutes: 1, seconds: 49)
    opts = %{race: %{start_at: datetime, timezone: "America/New_York"}}
    assert RaceView.countdown_timer(opts) =~ ~r/^2d 3h 1m 4[0-9]s$/
  end

  test "distance_type/1" do
    opts = %{race: %{distance_type: :half_marathon}}
    assert RaceView.distance_type(opts) == "Half Marathon"
  end
end
