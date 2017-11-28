defmodule Squeeze.Accounts.PaceTest do
  use Squeeze.DataCase

  alias Squeeze.Dashboard.Pace

  import Squeeze.Factory

  @valid_attrs params_for(:pace)
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Pace.changeset(%Pace{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Pace.changeset(%Pace{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "color must be valid hex color" do
    attrs = %{@valid_attrs | color: "#1234"}
    changeset = Pace.changeset(%Pace{}, attrs)
    assert %{color: ["has invalid format"]} = errors_on(changeset)
  end
end
