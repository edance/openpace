defmodule Squeeze.SocialTest do
  use Squeeze.DataCase

  alias Squeeze.Accounts
  alias Squeeze.Social

  describe "#list_following/1" do
    test "includes only followers" do
      %{follower: user, followee: user2} = insert(:follow)
      insert(:user)

      list = Social.list_following(user2)
      assert length(list) == 1
      assert List.first(list).id == user.id
    end
  end

  describe "#list_following/1" do
    test "includes only following users" do
      %{follower: user, followee: user2} = insert(:follow)
      insert(:user)

      list = Social.list_following(user)
      assert length(list) == 1
      assert List.first(list).id == user2.id
    end
  end

  describe "#follow_user/2" do
    test "creates follow record and increments counts" do
      [user, user2] = insert_pair(:user)
      Social.follow_user(user, user2)

      assert(Accounts.get_user_by_slug!(user.slug).following_count) == 1
      assert(Accounts.get_user_by_slug!(user2.slug).followers_count) == 1
      assert(length(Social.list_following(user))) == 1
    end
  end

  describe "#unfollow_user/2" do
    test "deletes follow record and decrements counts" do
      [user, user2] = insert_pair(:user, following_count: 1, follower_count: 1)
      insert(:follow, follower: user, followee: user2)
      Social.unfollow_user(user, user2)

      assert(Accounts.get_user_by_slug!(user.slug).following_count) == 0
      assert(Accounts.get_user_by_slug!(user2.slug).followers_count) == 0
      assert(Social.list_following(user)) == []
    end
  end
end
