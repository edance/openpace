defmodule SqueezeWeb.RaceViewTest do
  use SqueezeWeb.ConnCase, async: true

  alias SqueezeWeb.RaceView

  describe "title/2" do
    test "includes race name" do
      race = build(:race)
      assert RaceView.title(%{}, %{race: race}) =~ race.name
    end
  end

  test "location/1" do
    race = build(:race)
    assert RaceView.location(%{race: race}) == "#{race.city}, #{race.state} #{race.country}"
  end

  test "date/1" do
    race = build(:race) |> with_events()
    datetime = first_datetime(race)
    date = Ordinal.ordinalize(datetime.day)
    assert RaceView.date(%{race: race}) =~
      Timex.format!(datetime, "%a %b #{date}, %Y", :strftime)
  end

  test "time/1" do
    race = build(:race) |> with_events()
    datetime = first_datetime(race)
    assert RaceView.time(%{race: race}) ==
      Timex.format!(datetime, "%-I:%M %p ", :strftime)
  end

  describe "start_at/1" do
    test "without any events" do
      race = build(:race, events: [])
      assert RaceView.start_at(%{race: race}) == nil
    end

    test "with multiple events returns the first" do
      race = build(:race) |> with_events()
      assert RaceView.start_at(%{race: race}) == first_datetime(race)
    end
  end

  test "content/1" do
    race = build(:race, content: "## Test Heading")
    assert RaceView.content(%{race: race}) == {:safe, "<h2>Test Heading</h2>\n"}
  end

  defp first_datetime(race) do
    race.events |> Enum.map(&(&1.start_at)) |> Enum.min()
  end
end
