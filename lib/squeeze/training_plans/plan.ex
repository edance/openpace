defmodule Squeeze.TrainingPlans.Plan do
  @moduledoc """
  This module contains the schema for the training plans.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.User

  @required_fields ~w(name week_count)a
  @optional_fields ~w(experience_level description)a

  schema "training_plans" do
    field :name, :string
    field :experience_level, ExperienceLevelEnum
    field :week_count, :integer
    field :description, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(plan, attrs) do
    plan
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
