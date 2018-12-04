defmodule SqueezeWeb.OverviewViewTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :overview_view_case

  alias Squeeze.Accounts.User
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

  describe "#format_event" do
    test "returns Rest if nil event" do
      assert OverviewView.format_event(nil) == "Rest"
    end

    test "returns the name of the event" do
      name = "Boston Marathon"
      event = build(:event, %{name: name})
      assert OverviewView.format_event(event) == name
    end
  end
end
