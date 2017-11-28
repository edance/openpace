defmodule Squeeze.Accounts.UserTest do
  use Squeeze.DataCase

  alias Squeeze.Accounts.User

  import Squeeze.Factory

  @valid_attrs params_for(:user)
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

  test "email must contain at least an @" do
    attrs = %{@valid_attrs | email: "fooexample.com"}
    changeset = User.changeset(%User{}, attrs)
    assert %{email: ["has invalid format"]} = errors_on(changeset)
  end
end
