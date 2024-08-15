defmodule SqueezeWeb.Api.FollowControllerTest do
  use SqueezeWeb.ConnCase

  alias Squeeze.Social

  describe "#followers" do
    test "returns the followers for the given user", %{conn: conn} do
      %{follower: user1, followee: user2} = _follow = insert(:follow)
      # Additional unfollowed user
      insert(:user)

      conn = get(conn, api_follow_path(conn, :followers, user2.slug))
      assert [follower] = json_response(conn, 200)["followers"]
      assert follower["slug"] == user1.slug
    end
  end

  describe "#following" do
    test "returns the following users for the given user", %{conn: conn} do
      %{follower: user1, followee: user2} = insert(:follow)
      # Additional unfollowed user
      insert(:user)

      conn = get(conn, "/api/users/#{user1.slug}/following")
      assert [followee] = json_response(conn, 200)["following"]
      assert followee["slug"] == user2.slug
    end
  end

  describe "#follow" do
    test "creates a follow record and updates counts", %{conn: conn, user: user} do
      user2 = insert(:user)
      conn = post(conn, "/api/follow/#{user2.slug}")

      assert json_response(conn, 201)
      assert List.first(Social.list_following(user)).id == user2.id
    end

    test "fails if already following", %{conn: conn, user: user} do
      %{followee: user2} = insert(:follow, follower: user)
      conn = post(conn, "/api/follow/#{user2.slug}")

      assert json_response(conn, 422)
    end
  end

  describe "#unfollow" do
    test "deletes a follow record and updates counts", %{conn: conn, user: user} do
      %{followee: user2} = insert(:follow, follower: user)
      conn = delete(conn, "/api/unfollow/#{user2.slug}")

      assert response(conn, 204) == ""
      assert Social.list_following(user) == []
    end
  end
end
