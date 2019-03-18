defmodule Squeeze.RacesTest do
  use Squeeze.DataCase

  import Squeeze.Factory

  alias Squeeze.Races

  describe "races" do
    test "get_race!/1 returns the race with given id" do
      race = insert(:race)
      assert Races.get_race!(race.slug) == race
    end
  end
end
