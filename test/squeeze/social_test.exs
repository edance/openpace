defmodule Squeeze.SocialTest do
  use Squeeze.DataCase

  alias Squeeze.Social

  describe "followers" do
    alias Squeeze.Social.Follower

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def follower_fixture(attrs \\ %{}) do
      {:ok, follower} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Social.create_follower()

      follower
    end

    test "list_followers/0 returns all followers" do
      follower = follower_fixture()
      assert Social.list_followers() == [follower]
    end

    test "get_follower!/1 returns the follower with given id" do
      follower = follower_fixture()
      assert Social.get_follower!(follower.id) == follower
    end

    test "create_follower/1 with valid data creates a follower" do
      assert {:ok, %Follower{} = follower} = Social.create_follower(@valid_attrs)
    end

    test "create_follower/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Social.create_follower(@invalid_attrs)
    end

    test "update_follower/2 with valid data updates the follower" do
      follower = follower_fixture()
      assert {:ok, %Follower{} = follower} = Social.update_follower(follower, @update_attrs)
    end

    test "update_follower/2 with invalid data returns error changeset" do
      follower = follower_fixture()
      assert {:error, %Ecto.Changeset{}} = Social.update_follower(follower, @invalid_attrs)
      assert follower == Social.get_follower!(follower.id)
    end

    test "delete_follower/1 deletes the follower" do
      follower = follower_fixture()
      assert {:ok, %Follower{}} = Social.delete_follower(follower)
      assert_raise Ecto.NoResultsError, fn -> Social.get_follower!(follower.id) end
    end

    test "change_follower/1 returns a follower changeset" do
      follower = follower_fixture()
      assert %Ecto.Changeset{} = Social.change_follower(follower)
    end
  end
end
