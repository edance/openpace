defmodule Squeeze.Dashboard.ActivityTest do
  use Squeeze.DataCase

  alias Squeeze.Dashboard.Activity

  import Squeeze.Factory

  @valid_attrs params_for(:activity)
  @invalid_attrs params_for(:activity, name: nil)

  test "changeset with valid attributes" do
    changeset = Activity.changeset(%Activity{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Activity.changeset(%Activity{}, @invalid_attrs)
    assert !changeset.valid?
  end
end
