defmodule SqueezeWeb.OverviewViewTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :overview_view_case

  alias Squeeze.Accounts.User
  alias SqueezeWeb.FormatHelpers
  alias SqueezeWeb.OverviewView

  test "title includes sign in" do
    assert OverviewView.title(%{}, %{}) =~ "Dashboard"
  end

  test "#full_name is User.full_name" do
    user = build(:user)
    assert OverviewView.full_name(user) == User.full_name(user)
  end

  test "#improvement_amount is User.improvement_amount" do
    user = build(:user)
    assert OverviewView.improvement_amount(user) == User.improvement_amount(user)
  end

  test "#race_date formats the date" do
    {:ok, date} = Date.new(2018, 11, 11)
    user = build(:user, %{user_prefs: %{race_date: date}})
    assert OverviewView.race_date(user) == "Nov 11th"
  end

  test "#format_goal" do
    user = build(:user, %{user_prefs: %{duration: 3 * 60 * 60}})
    assert OverviewView.format_goal(user) == "3:00:00"
  end

  test "#race_date" do
    {:ok, date} = Date.new(2018, 1, 1)
    user = build(:user, %{user_prefs: %{race_date: date}})
    assert OverviewView.race_date(user) == "Jan 1st"
  end

  describe "#weeks_until_race" do
    test "without a race date" do
      user_prefs = build(:user_prefs, %{race_date: nil})
      user = build(:user, user_prefs: user_prefs)
      assert OverviewView.weeks_until_race(user) == nil
    end

    test "with valid date" do
      user = build(:user)
      date = user.user_prefs.race_date
      weeks_until = OverviewView.weeks_until_race(user)
      assert weeks_until == FormatHelpers.relative_date(user, date)
    end
  end
end
