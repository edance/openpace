defmodule SqueezeWeb.DashboardViewTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :dashboard_view_case

  alias SqueezeWeb.DashboardView

  test "title includes sign in" do
    assert DashboardView.title(%{}, %{}) =~ "Dashboard"
  end

  describe "#full_name" do
    test "returns first and last name" do
      user = build(:user)
      assert DashboardView.full_name(user) == "#{user.first_name} #{user.last_name}"
    end

    test "returns just the first name if last name is nil" do
      user = build(:user, %{last_name: nil})
      assert DashboardView.full_name(user) == user.first_name
    end
  end

  describe "#race_name" do
    test "converts the distance in meters to a string" do
      user = build(:user, %{user_prefs: %{distance: 5_000}})
      assert DashboardView.race_name(user) == "5k"
    end
  end

  describe "#improvement_amount" do
    test "returns nil without a personal record" do
      user = build(:user, %{user_prefs: %{personal_record: nil}})
      assert DashboardView.improvement_amount(user) == nil
    end

    test "returns percentage improvement" do
      user = build(:user, %{user_prefs: %{personal_record: 3, duration: 2}})
      assert DashboardView.improvement_amount(user) == "33.3%"
    end
  end

  test "#race_date formats the date" do
    {:ok, date} = Date.new(2018, 11, 11)
    user = build(:user, %{user_prefs: %{race_date: date}})
    assert DashboardView.race_date(user) == "Nov 11th"
  end

  describe "#format_event" do
    test "returns Rest if nil event" do
      assert DashboardView.format_event(nil) == "Rest"
    end

    test "returns the name of the event" do
      name = "Boston Marathon"
      event = build(:event, %{name: name})
      assert DashboardView.format_event(event) == name
    end
  end
end
