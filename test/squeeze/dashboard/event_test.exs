defmodule Squeeze.Dashboard.EventTest do
  use Squeeze.DataCase

  alias Squeeze.Dashboard.Event

  import Squeeze.Factory

  @valid_attrs params_for(:event)
  @invalid_attrs params_for(:event, distance: nil)

  test "changeset with valid attributes" do
    changeset = Event.changeset(%Event{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Event.changeset(%Event{}, @invalid_attrs)
    refute changeset.valid?
  end
end
