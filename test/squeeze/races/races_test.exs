defmodule Squeeze.RacesTest do
  use Squeeze.DataCase

  import Squeeze.Factory

  alias Squeeze.Races

  describe "races" do
    test "get_race!/1 returns the race with given slug" do
      race = insert(:race)
      slug = race.slug
      assert Races.get_race!(slug).slug == slug
    end
  end
end
