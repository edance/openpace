defmodule Squeeze.AccountsTest do
  use Squeeze.DataCase

  alias Squeeze.Accounts

  describe "users" do
    alias Squeeze.Accounts.User

    @valid_attrs %{first_name: "Pat", last_name: "Tester", credential: nil}
    @update_attrs %{first_name: "Brian"}
    @invalid_attrs %{first_name: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.first_name == @valid_attrs.first_name
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.first_name == @update_attrs.first_name
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "credentials" do
    alias Squeeze.Accounts.Credential

    @valid_attrs %{
      first_name: "Test",
      last_name: "Test",
      credential: %{provider: "some provider", token: "some token", uid: 1234}
    }

    def credential_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user.credential
    end

    test "get_credential!/2 returns the credential with given id" do
      credential = credential_fixture()
      assert Accounts.get_credential(credential.provider, credential.uid).id == credential.id
    end
  end
end
