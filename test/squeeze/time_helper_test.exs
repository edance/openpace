defmodule Squeeze.TimeHelperTest do
  use Squeeze.DataCase

  @moduledoc false

  import Squeeze.Factory

  alias Squeeze.TimeHelper

  setup [:create_user]

  describe "to_date/2" do
    test "returns a date based on the users timezone", %{user: user} do
      datetime = Timex.beginning_of_day(Timex.now()) # UTC 00:00 of today
      date = datetime |> Timex.shift(days: -1) |> Timex.to_date() # One day ago in New York
      assert TimeHelper.to_date(user, datetime) == date
    end
  end

  describe "beginning_of_day/2" do
    test "returns the utc datetime for the beginning of the day", %{user: user} do
      now = Timex.now()
      date = Timex.to_date(now)
      beginning_of_day = Timex.beginning_of_day(Timex.now())
      datetime = TimeHelper.beginning_of_day(user, date)
      diff = Timex.diff(datetime, beginning_of_day, :hours)
      # New York is either 4 or 5 hours behind depending on Daylight Savings
      assert diff == 4 || diff == 5
    end
  end

  describe "end_of_day/2" do
    test "returns the utc datetime for the end of the day", %{user: user} do
      now = Timex.now()
      date = Timex.to_date(now)
      end_of_day = Timex.end_of_day(now)
      datetime = TimeHelper.end_of_day(user, date)
      diff = Timex.diff(datetime, end_of_day, :hours)
      # New York is either 4 or 5 hours behind depending on Daylight Savings
      assert diff == 4 || diff == 5
    end
  end

  # Default timezone for a user is New York
  defp create_user(_) do
    {:ok, user: build(:user)}
  end
end
