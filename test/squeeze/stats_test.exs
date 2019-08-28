defmodule Squeeze.StatsTest do
  use Squeeze.DataCase

  @moduledoc false

  import Squeeze.Factory
  alias Squeeze.Stats

  describe "dataset_for_year_chart/1" do
    setup [:build_user]

    test "returns the last 14 weeks", %{user: user} do
      data = Stats.dataset_for_year_chart(user)
      assert length(data) == 14
    end
  end

  describe "dataset_for_week_chart/1" do
    setup [:build_user]

    test "returns the last seven days", %{user: user} do
      data = Stats.dataset_for_week_chart(user)
      assert length(data) == 7
    end
  end

  describe "weekly_dateset/1" do
    setup [:build_user]

    test "returns seven days of the week", %{user: user} do
      dates = Stats.weekly_dateset(user)
      assert length(dates) == 7
    end
  end

  describe "yearly_dateset/1" do
    setup [:build_user]

    test "returns the last 14 weeks", %{user: user} do
      dates = Stats.yearly_dateset(user)
      assert length(dates) == 14
    end
  end

  defp build_user(_) do
    {:ok, user: build(:user)}
  end
end
