defmodule Squeeze.TrainingPlans.Event do
  @moduledoc """
  This module contains the schema for the training plans.
  """

  use Ecto.Schema

  alias Squeeze.TrainingPlans.{Plan}

  schema "training_events" do
    field :name, :string
    field :distance, :float
    field :duration, :integer

    field :warmup, :boolean
    field :cooldown, :boolean

    field :plan_position, :integer
    field :day_position, :integer

    belongs_to :plan, Plan, foreign_key: :training_plan_id

    timestamps()
  end
end
