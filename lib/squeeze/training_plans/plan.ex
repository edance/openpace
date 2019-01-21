defmodule Squeeze.TrainingPlans.Plan do
  @moduledoc """
  This module contains the schema for the training plans.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Accounts.User

  schema "training_plans" do
    field :name, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(plan, attrs) do
    plan
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
