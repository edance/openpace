defmodule Squeeze.Accounts.UserTest do
  use Squeeze.DataCase

  alias Squeeze.Accounts.User

  import Squeeze.Factory

  @valid_attrs params_for(:user)

  test "changeset with full attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with no attributes" do
    changeset = User.changeset(%User{}, %{})
    assert changeset.valid?
  end

  test "email must contain at least an @" do
    attrs = %{@valid_attrs | email: "fooexample.com"}
    changeset = User.changeset(%User{}, attrs)
    assert %{email: ["has invalid format"]} = errors_on(changeset)
  end
end
