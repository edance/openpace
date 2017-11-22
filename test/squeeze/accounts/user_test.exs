defmodule Squeeze.Accounts.UserTest do
  use Squeeze.DataCase

  alias Squeeze.Accounts.User

  @valid_attrs %{first_name: "Pat", last_name: "Example", description: "test"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "description is not required" do
    changeset = User.changeset(%User{}, Map.delete(@valid_attrs, :description))
    assert changeset.valid?
  end
end
