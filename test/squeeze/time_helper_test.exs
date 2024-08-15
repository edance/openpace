defmodule Squeeze.TimeHelperTest do
  use Squeeze.DataCase

  @moduledoc false

  import Squeeze.Factory

  alias Squeeze.TimeHelper

  setup [:create_user]

  describe "to_date/2" do
    test "with a DateTime returns a date based on the users timezone", %{user: user} do
      # UTC 00:00 of today
      datetime = Timex.beginning_of_day(Timex.now())
      # One day ago in New York
      date = datetime |> Timex.shift(days: -1) |> Timex.to_date()
      assert TimeHelper.to_date(user, datetime) == date
    end

    test "with a NaiveDateTime returns a date based on the users timezone", %{user: user} do
      # UTC 00:00 of today
      datetime = Timex.beginning_of_day(Timex.now())
      date = DateTime.to_date(datetime)
      time = DateTime.to_time(datetime)
      {:ok, naive_datetime} = NaiveDateTime.new(date, time)

      assert TimeHelper.to_date(user, naive_datetime) ==
               TimeHelper.to_date(user, datetime)
    end
  end

  describe "beginning_of_day/2" do
    test "returns the utc datetime for the beginning of the day", %{user: user} do
      now = Timex.now()
      date = Timex.to_date(now)

      datetime =
        date
        |> Timex.to_datetime(user.user_prefs.timezone)
        |> Timex.beginning_of_day()
        |> Timex.to_datetime()

      assert TimeHelper.beginning_of_day(user, date) == datetime
    end
  end

  # Default timezone for a user is New York
  defp create_user(_) do
    {:ok, user: build(:user)}
  end
end
