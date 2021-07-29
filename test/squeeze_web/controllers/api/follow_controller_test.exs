defmodule SqueezeWeb.Api.FollowControllerTest do
  use SqueezeWeb.ConnCase

  alias Squeeze.Social
  alias Squeeze.Social.Follow

  describe "#followers" do
    test "returns the followers for the given user", %{conn: conn} do
      %{follower: user1, followee: user2} = insert(:follow)
      insert(:user) # Additional unfollowed user

      conn = get(conn, "/api/users/#{user2.slug}/followers")
      assert [follower] = json_response(conn, 200)["followers"]
      assert follower.id == user1.id
    end
  end

  describe "#following" do
    test "returns the following users for the given user", %{conn: conn} do
      %{follower: user1, followee: user2} = insert(:follow)
      insert(:user) # Additional unfollowed user

      conn = get(conn, "/api/users/#{user1.slug}/following")
      assert [followee] = json_response(conn, 200)["following"]
      assert followee.id == user2.id
    end
  end

  describe "#follow" do
    test "creates a follow record and updates counts", %{conn: conn, user: user} do
      user2 = insert(:user)
      conn = post(conn, "/api/follow/#{user2.slug}")

      assert json_response(conn, 201)
      assert List.first(Social.list_following(user)).id == user2.id
      assert Accounts.get_user_by_slug!(user.slug).following_count == 1
      assert Accounts.get_user_by_slug!(user2.slug).follower_count == 1
    end

    test "fails if already following", %{conn: conn} do
      %{followee: user2} = insert(:follow, follower: user)
      conn = post(conn, "/api/follow/#{user2.slug}")

      assert json_response(conn, 400)
    end
  end

  describe "#unfollow" do
    test "deletes a follow record and updates counts", %{conn: conn, user: user} do
      %{followee: user2} = insert(:follow, follower: user)
      conn = post(conn, "/api/unfollow/#{user2.slug}")

      assert json_response(conn, 204)
      assert Social.list_following(user) == []
      assert Accounts.get_user_by_slug!(user.slug).following_count == 0
      assert Accounts.get_user_by_slug!(user2.slug).follower_count == 0
    end

    test "fails if already following", %{conn: conn} do
      user2 = insert(:user)
      conn = post(conn, "/api/follow/#{user2.slug}")

      assert json_response(conn, 400)
    end
  end
end
