defmodule Squeeze.TrainingPlans.Event do
  @moduledoc false

  use Ecto.Schema

  alias Squeeze.TrainingPlans.{Plan}

  schema "training_events" do
    field :name, :string
    field :distance, :float
    field :duration, :integer
    field :type, :string

    field :warmup, :boolean
    field :cooldown, :boolean

    field :plan_position, :integer
    field :day_position, :integer

    belongs_to :plan, Plan, foreign_key: :training_plan_id

    timestamps()
  end
end
