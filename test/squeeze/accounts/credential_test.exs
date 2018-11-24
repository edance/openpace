defmodule Squeeze.Accounts.CredentialTest do
  use Squeeze.DataCase

  alias Squeeze.Accounts.Credential

  import Squeeze.Factory

  @valid_attrs params_for(:credential)

  test "changeset with full attributes" do
    changeset = Credential.changeset(%Credential{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with no attributes" do
    changeset = Credential.changeset(%Credential{}, %{})
    refute changeset.valid?
  end
end
