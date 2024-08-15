defmodule SqueezeWeb.ModalView do
  use SqueezeWeb, :view
  @moduledoc false

  def activity_types do
    [
      "Run",
      "Bike",
      "Swim",
      "Cross Training",
      "Walk",
      "Strength Training",
      "Workout",
      "Yoga"
    ]
  end

  def workout_types do
    [
      Race: "race",
      "Long Run": "long_run",
      Workout: "workout"
    ]
  end
end
