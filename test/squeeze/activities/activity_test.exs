defmodule Squeeze.Activities.ActivityTest do
  use Squeeze.DataCase

  alias Squeeze.Activities.Activity
  alias Squeeze.Repo

  import Squeeze.Factory

  @valid_attrs params_for(:activity)
  @invalid_attrs params_for(:activity, type: nil)

  test "changeset with valid attributes" do
    changeset = Activity.changeset(%Activity{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Activity.changeset(%Activity{}, @invalid_attrs)
    assert !changeset.valid?
  end

  test "with a duplicate slug, it appends to slug" do
    %{slug: slug} = insert(:activity)
    changeset = Activity.changeset(%Activity{}, @valid_attrs)

    {:ok, activity} = Repo.insert_with_slug(changeset, slug: slug)
    refute slug == activity.slug
  end
end
