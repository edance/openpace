defmodule Squeeze.NotificationsTest do
  use Squeeze.DataCase

  import Squeeze.Factory

  alias Squeeze.Notifications
  alias Squeeze.Notifications.PushToken

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
