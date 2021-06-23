defmodule Squeeze.NotificationsTest do
  use Squeeze.DataCase

  import Mox
  import Squeeze.Factory

  alias Squeeze.Notifications
  alias Squeeze.Notifications.PushToken

  describe "#batch_notify_challenge_start/0" do
    setup do
      now = Timex.now("America/New_York")
      challenge = insert(:challenge, start_date: now) |> with_scores(1)
      [score] = challenge.scores
      push_token = insert(:push_token, token: "ABC", user: score.user)

      {:ok, challenge: challenge, push_token: push_token}
    end

    test "only notifies for challenges starting today" do
      now = Timex.now("America/New_York") |> Timex.set(hour: 9) # Today at 9 am
      challenge = insert(:challenge, start_date: Timex.shift(now, days: -1)) |> with_scores(1)
      [score] = challenge.scores
      insert(:push_token, user: score.user)

      Squeeze.ExpoNotifications.MockNotificationProvider
      |> expect(:push_list, fn([%{to: "ABC"}]) -> {:ok, []} end)

      Notifications.batch_notify_challenge_start(now)
    end

    test "only notifies at 9am" do
      now = Timex.now("America/New_York") |> Timex.set(hour: 8) # Today at 8 am

      Notifications.batch_notify_challenge_start(now)
    end
  end

  describe "#batch_notify_challenge_ending" do
    setup do
      now = Timex.now("America/New_York")
      challenge = insert(:challenge, end_date: now) |> with_scores(1)
      [score] = challenge.scores
      insert(:push_token, token: "ABC", user: score.user)

      {:ok, []}
    end

    test "only notifies for challenges ending today" do
      now = Timex.now("America/New_York") |> Timex.set(hour: 9) # Today at 9 am
      insert(:challenge, end_date: Timex.shift(now, days: 1)) |> with_scores(1)

      Squeeze.ExpoNotifications.MockNotificationProvider
      |> expect(:push_list, fn([%{to: "ABC"}]) -> {:ok, []} end)

      Notifications.batch_notify_challenge_start(now)
    end
  end

  describe "#batch_notify_challenge_ended" do
    setup do
      now = Timex.now("America/New_York") |> Timex.shift(days: -1)
      challenge = insert(:challenge, end_date: now) |> with_scores(1)
      [score] = challenge.scores
      insert(:push_token, token: "ABC", user: score.user)

      {:ok, []}
    end

    test "only notifies for challenges ended yesterday" do
      now = Timex.now("America/New_York") |> Timex.set(hour: 9) # Today at 9 am
      insert(:challenge, end_date: now) |> with_scores(1)

      Squeeze.ExpoNotifications.MockNotificationProvider
      |> expect(:push_list, fn([%{to: "ABC"}]) -> {:ok, []} end)

      Notifications.batch_notify_challenge_start(now)
    end
  end

  describe "#notify_new_activity/1" do
  end

  describe "#notify_user_joined/2" do
  end

  describe "#notify_leader_change/1" do
  end

  describe "#notify_challenge_started/1" do
  end

  describe "#notify_challenge_ended/1" do
  end

  describe "#notify_challenge_ending/1" do
  end

  describe "#create_push_token/2" do
    test "creates a push token with valid data" do
      user = insert(:user)
      params = params_for(:push_token)
      token = params[:token]
      assert {:ok, %PushToken{}} = Notifications.create_push_token(user, token)
    end

    test "errors if the push token already exists" do
      token = insert(:push_token)
      user = token.user
      params = %{token: token.token}
      assert {:error, _} = Notifications.create_push_token(user, params)
    end

    test "errors with invalid data" do
      user = insert(:user)
      assert {:error, _} = Notifications.create_push_token(user, %{})
    end
  end

  describe "#delete_push_token/1" do
    test "deletes the push token if it exists" do
      token = insert(:push_token)
      assert {:ok, _} = Notifications.delete_push_token(token)
    end
  end
end
