defmodule Squeeze.StatsTest do
  use Squeeze.DataCase

  import Squeeze.Factory

  alias Squeeze.Stats

  @moduledoc false

  describe "#years_active/1" do
    test "includes only the users activity" do
      user = insert(:user)
      start_at = Timex.now("America/Los_Angeles") |> Timex.set(year: 2000)
      insert(:activity, user: user, start_at: start_at)
      insert(:activity, start_at: start_at |> Timex.set(year: 2001))

      assert ["2000"] == Stats.years_active(user)
    end

    test "returns all years active in order" do
      user = insert(:user)
      start_at = Timex.now("America/Los_Angeles")
      insert(:activity, user: user, start_at: start_at |> Timex.set(year: 2000))
      insert(:activity, user: user, start_at: start_at |> Timex.set(year: 2002))

      assert ["2000", "2002"] == Stats.years_active(user)
    end
  end
end
