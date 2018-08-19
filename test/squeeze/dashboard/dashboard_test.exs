defmodule Squeeze.DashboardTest do
  use Squeeze.DataCase

  alias Squeeze.Dashboard

  import Squeeze.Factory

  # describe "events" do
  #   alias Squeeze.Dashboard.Event

  #   @update_attrs %{name: "some updated name"}
  #   @invalid_attrs %{date: nil, distance: nil}

  #   test "list_events/2 returns events in date range" do
  #     user = insert(:user)
  #     yesterday = Timex.today |> Timex.shift(days: -1)
  #     insert(:event, date: yesterday, user: user)
  #     current = insert(:event, date: Timex.today, user: user)
  #     range = Date.range(Timex.today, Timex.shift(Timex.today, days: 1))
  #     events = Dashboard.list_events(user, range)
  #     assert Enum.map(events, fn x -> x.id end) == [current.id]
  #   end

  #   test "get_event!/1 returns the event with given id" do
  #     event = insert(:event)
  #     assert Dashboard.get_event!(event.id).id == event.id
  #   end

  #   test "create_event/2 with valid data creates a event" do
  #     user = insert(:user)
  #     attrs = %{params_with_assocs(:event) | name: "Test Event"}
  #     assert {:ok, %Event{} = event} = Dashboard.create_event(user, attrs)
  #     assert event.name == "Test Event"
  #   end

  #   test "create_event/2 with invalid data returns error changeset" do
  #     user = insert(:user)
  #     assert {:error, %Ecto.Changeset{}} = Dashboard.create_event(user, @invalid_attrs)
  #   end

  #   test "update_event/2 with valid data updates the event" do
  #     event = insert(:event)
  #     assert {:ok, event} = Dashboard.update_event(event, @update_attrs)
  #     assert %Event{} = event
  #     assert event.name == "some updated name"
  #   end

  #   test "update_event/2 with invalid data returns error changeset" do
  #     event = insert(:event)
  #     assert {:error, %Ecto.Changeset{}} = Dashboard.update_event(event, @invalid_attrs)
  #     assert event.id == Dashboard.get_event!(event.id).id
  #   end

  #   test "delete_event/1 deletes the event" do
  #     event = insert(:event)
  #     assert {:ok, %Event{}} = Dashboard.delete_event(event)
  #     assert_raise Ecto.NoResultsError, fn -> Dashboard.get_event!(event.id) end
  #   end

  #   test "change_event/1 returns a event changeset" do
  #     event = insert(:event)
  #     assert %Ecto.Changeset{} = Dashboard.change_event(event)
  #   end
  # end

  # describe "activities" do
  #   alias Squeeze.Dashboard.Activity

  #   @valid_attrs params_for(:activity)
  #   @update_attrs %{name: "some updated name"}
  #   @invalid_attrs %{distance: nil, duration: nil, name: nil, start_at: nil}

  #   test "list_activities/1 returns all activities" do
  #     activity = insert(:activity)
  #     assert Dashboard.list_activities(activity.user) == [activity]
  #   end

  #   test "get_activity!/1 returns the activity with given id" do
  #     activity = insert(:activity)
  #     assert Dashboard.get_activity!(activity.id) == activity
  #   end

  #   test "create_activity/2 with valid data creates a activity" do
  #     user = insert(:user)
  #     assert {:ok, %Activity{} = activity} = Dashboard.create_activity(user, @valid_attrs)
  #     assert activity.name == @valid_attrs.name
  #   end

  #   test "create_activity/2 with invalid data returns error changeset" do
  #     user = insert(:user)
  #     assert {:error, %Ecto.Changeset{}} = Dashboard.create_activity(user, @invalid_attrs)
  #   end

  #   test "update_activity/2 with valid data updates the activity" do
  #     activity = insert(:activity)
  #     assert {:ok, activity} = Dashboard.update_activity(activity, @update_attrs)
  #     assert %Activity{} = activity
  #     assert activity.name == "some updated name"
  #   end

  #   test "update_activity/2 with invalid data returns error changeset" do
  #     activity = insert(:activity)
  #     assert {:error, %Ecto.Changeset{}} = Dashboard.update_activity(activity, @invalid_attrs)
  #     assert activity == Dashboard.get_activity!(activity.id)
  #   end

  #   test "delete_activity/1 deletes the activity" do
  #     activity = insert(:activity)
  #     assert {:ok, %Activity{}} = Dashboard.delete_activity(activity)
  #     assert_raise Ecto.NoResultsError, fn -> Dashboard.get_activity!(activity.id) end
  #   end

  #   test "change_activity/1 returns a activity changeset" do
  #     activity = insert(:activity)
  #     assert %Ecto.Changeset{} = Dashboard.change_activity(activity)
  #   end
  # end
end
