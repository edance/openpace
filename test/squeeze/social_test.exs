defmodule Squeeze.SocialTest do
  use Squeeze.DataCase

  alias Squeeze.Social

  describe "follows" do
    alias Squeeze.Social.Follow

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def follow_fixture(attrs \\ %{}) do
      {:ok, follow} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Social.create_follow()

      follow
    end

    test "list_follows/0 returns all follows" do
      follow = follow_fixture()
      assert Social.list_follows() == [follow]
    end

    test "get_follow!/1 returns the follow with given id" do
      follow = follow_fixture()
      assert Social.get_follow!(follow.id) == follow
    end

    test "create_follow/1 with valid data creates a follow" do
      assert {:ok, %Follow{} = follow} = Social.create_follow(@valid_attrs)
    end

    test "create_follow/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Social.create_follow(@invalid_attrs)
    end

    test "update_follow/2 with valid data updates the follow" do
      follow = follow_fixture()
      assert {:ok, %Follow{} = follow} = Social.update_follow(follow, @update_attrs)
    end

    test "update_follow/2 with invalid data returns error changeset" do
      follow = follow_fixture()
      assert {:error, %Ecto.Changeset{}} = Social.update_follow(follow, @invalid_attrs)
      assert follow == Social.get_follow!(follow.id)
    end

    test "delete_follow/1 deletes the follow" do
      follow = follow_fixture()
      assert {:ok, %Follow{}} = Social.delete_follow(follow)
      assert_raise Ecto.NoResultsError, fn -> Social.get_follow!(follow.id) end
    end

    test "change_follow/1 returns a follow changeset" do
      follow = follow_fixture()
      assert %Ecto.Changeset{} = Social.change_follow(follow)
    end
  end
end
