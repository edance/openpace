defmodule SqueezeWeb.OverviewViewTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :overview_view_case

  alias SqueezeWeb.OverviewView

  test "title includes sign in" do
    assert OverviewView.title(%{}, %{}) =~ "Dashboard"
  end

  describe "#full_name" do
    test "returns first and last name" do
      user = build(:user)
      assert OverviewView.full_name(user) == "#{user.first_name} #{user.last_name}"
    end

    test "returns just the first name if last name is nil" do
      user = build(:user, %{last_name: nil})
      assert OverviewView.full_name(user) == user.first_name
    end
  end

  describe "#improvement_amount" do
    test "returns nil without a personal record" do
      user = build(:user, %{user_prefs: %{personal_record: nil}})
      assert OverviewView.improvement_amount(user) == nil
    end

    test "returns percentage improvement" do
      user = build(:user, %{user_prefs: %{personal_record: 3, duration: 2}})
      assert OverviewView.improvement_amount(user) == "33.3%"
    end
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
