defmodule Squeeze.Accounts.UserPrefsTest do
  use Squeeze.DataCase

  alias Squeeze.Accounts.UserPrefs

  import Squeeze.Factory

  @valid_attrs params_for(:user_prefs)

  test "changeset with full attributes" do
    changeset = UserPrefs.changeset(%UserPrefs{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with no attributes" do
    changeset = UserPrefs.changeset(%UserPrefs{}, %{})
    assert changeset.valid?
  end

  test "with a complete profile" do
    user = insert(:user)
    assert UserPrefs.complete?(user.user_prefs)
  end
end
