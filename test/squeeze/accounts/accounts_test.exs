defmodule Squeeze.AccountsTest do
  use Squeeze.DataCase

  alias Squeeze.Accounts

  import Squeeze.Factory

  describe "users" do
    alias Squeeze.Accounts.User

    @valid_attrs params_for(:user)
    @update_attrs %{first_name: "Brian"}
    @invalid_attrs %{first_name: nil}

    test "get_user!/1 returns the user with given id" do
      user = insert(:user)
      assert Accounts.get_user!(user.id).id == user.id
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.first_name == @valid_attrs.first_name
    end

    test "update_user/2 with valid data updates the user" do
      user = insert(:user)
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.first_name == "Brian"
    end

    test "delete_user/1 deletes the user" do
      user = insert(:user)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = insert(:user)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "credentials" do
    test "get_credential!/2 returns the credential with given id" do
      credential = insert(:credential)
      assert Accounts.get_credential(credential.provider, credential.uid).id == credential.id
    end
  end
end
