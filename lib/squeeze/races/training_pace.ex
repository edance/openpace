defmodule Squeeze.Races.TrainingPace do
  @moduledoc """
  This module defines the training paces. Currently this model is embedded.
  """

  use Ecto.Schema

  alias Squeeze.Colors
  alias Squeeze.RacePredictor
  alias Squeeze.Races.RaceGoal

  import Squeeze.Distances, only: [marathon_in_meters: 0, mile_in_meters: 0]

  embedded_schema do
    field :color, :string
    field :name, :string
    field :long, :boolean # This only counts if the run has been marked "long"
    field :speed, :float # meters per second
    field :min_speed, :float # meters per second
    field :max_speed, :float # meters per second
  end

  def default_paces(distance, duration) do
    # Easy: MP + 1-2min (need to research more)
    # LR: 25-30% of weekly mileage
    # Marathon pace: MP
    # Strength/Tempo: MP - 10 sec
    # 10k speed: Use race predictor
    # 5k speed: Use race predictor
    vo2_max = RacePredictor.estimated_vo2max(distance, duration)
    marathon_speed = marathon_speed(distance, duration, vo2_max)

    [
      easy_pace(marathon_speed, vo2_max),
      long_pace(marathon_speed, vo2_max),
      marathon_pace(marathon_speed, vo2_max),
      tempo_pace(marathon_speed, vo2_max),
      tenk_pace(marathon_speed, vo2_max),
      fivek_pace(marathon_speed, vo2_max)
    ]
  end

  # Adjust the pace up or down by 1-2 minutes
  #
  # (1609/60)
  # ----------   =   m/sec
  #  min/mile

  # (1609/60)
  # ---------   =  min/mile
  #   m/sec
  def adjust_pace_by_secs(pace, offset) do
    secs_per_mile = mile_in_meters() / pace
    new_pace = secs_per_mile + offset
    mile_in_meters() / new_pace
  end

  # Easy: 1:30-2:30min on MP per mile
  # Moderate: 1-2min
  def easy_pace(marathon_speed, _vo2_max) do
    %{
      color: Colors.green(),
      name: "Easy",
      long: false,
      min_speed: adjust_pace_by_secs(marathon_speed, 150),
      max_speed: adjust_pace_by_secs(marathon_speed, 60)
    }
  end

  # Long Run: 30sec-2min
  def long_pace(marathon_speed, _vo2_max) do
    %{
      color: Colors.teal(),
      name: "Long Run",
      long: true,
      min_speed: adjust_pace_by_secs(marathon_speed, 120),
      max_speed: adjust_pace_by_secs(marathon_speed, 30)
    }
  end

  def marathon_pace(marathon_speed, _vo2_max) do
    %{
      color: Colors.blue(),
      name: "Marathon",
      long: false,
      speed: marathon_speed
    }
  end

  def tempo_pace(marathon_speed, _vo2_max) do
    %{
      color: Colors.yellow(),
      name: "Tempo",
      long: false,
      speed: adjust_pace_by_secs(marathon_speed, -10)
    }
  end

  def tenk_pace(_marathon_speed, vo2_max) do
    distance = 10_000
    t = RacePredictor.predict_race_time(distance, vo2_max)
    %{
      color: Colors.orange(),
      name: "10k",
      long: false,
      speed: distance / t
    }
  end

  def fivek_pace(_marathon_speed, vo2_max) do
    distance = 5_000
    t = RacePredictor.predict_race_time(distance, vo2_max)
    %{
      color: Colors.red(),
      name: "5k",
      long: false,
      speed: distance / t
    }
  end

  # Base pace is your marathon pace or equivalent
  defp marathon_speed(distance, duration, vo2_max) do
    if distance == marathon_in_meters() do
      distance / duration
    else
      marathon_in_meters()
      |> RacePredictor.predict_race_time(vo2_max)
      |> Kernel./(marathon_in_meters())
    end
  end
end
