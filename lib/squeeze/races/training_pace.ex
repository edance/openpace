defmodule Squeeze.Races.TrainingPace do
  @moduledoc """
  This module defines the training paces. Currently this model is embedded.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Squeeze.Colors
  alias Squeeze.RacePredictor
  alias Squeeze.Races.{RaceGoal, TrainingPace}
  alias Squeeze.Velocity

  import Squeeze.Distances, only: [marathon_in_meters: 0, mile_in_meters: 0]

  schema "training_paces" do
    field :color, :string
    field :name, :string
    # meters per second
    field :min_speed, Velocity
    # meters per second
    field :max_speed, Velocity

    belongs_to :race_goal, RaceGoal

    timestamps()
  end

  @doc false
  def changeset(%TrainingPace{} = pace, attrs) do
    pace
    |> cast(attrs, [:color, :name, :min_speed, :max_speed])
    |> validate_required([:color, :name, :min_speed, :max_speed])
    |> validate_number(:min_speed, greater_than_or_equal_to: 0)
    |> validate_number(:max_speed, greater_than: 0)
    |> validate_max_speed_greater_than_min_speed()
  end

  def default_paces(%{duration: nil}), do: []
  def default_paces(%{duration: 0}), do: []

  def default_paces(%{distance: distance, duration: duration}) do
    # Easy: MP + 1-2min (need to research more)
    # LR: 25-30% of weekly mileage
    # Marathon pace: MP +/- 10 secs
    # Strength/Tempo: MP - 10 secs through 88% of vo2max
    # Interval pace: 95%-100% of vo2max
    # Repetition pace: 105%-110% of vo2max
    vo2max = RacePredictor.estimated_vo2max(distance, duration)
    marathon_speed = marathon_speed(distance, duration, vo2max)

    [
      easy_pace(marathon_speed, vo2max),
      long_pace(marathon_speed, vo2max),
      marathon_pace(marathon_speed, vo2max),
      tempo_pace(marathon_speed, vo2max),
      interval_pace(marathon_speed, vo2max),
      repetition_pace(marathon_speed, vo2max)
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
  def easy_pace(marathon_speed, _vo2max) do
    %{
      color: Colors.green(),
      name: "Easy",
      min_speed: adjust_pace_by_secs(marathon_speed, 150),
      max_speed: adjust_pace_by_secs(marathon_speed, 60)
    }
  end

  # Long Run: 30sec-2min
  def long_pace(marathon_speed, _vo2max) do
    %{
      color: Colors.teal(),
      name: "Long Run",
      min_speed: adjust_pace_by_secs(marathon_speed, 120),
      max_speed: adjust_pace_by_secs(marathon_speed, 30)
    }
  end

  def marathon_pace(marathon_speed, _vo2max) do
    %{
      color: Colors.blue(),
      name: "Marathon",
      min_speed: adjust_pace_by_secs(marathon_speed, -10),
      max_speed: adjust_pace_by_secs(marathon_speed, 10)
    }
  end

  def tempo_pace(marathon_speed, vo2max) do
    %{
      color: Colors.yellow(),
      name: "Tempo",
      min_speed: adjust_pace_by_secs(marathon_speed, -10),
      max_speed: RacePredictor.velocity_at_vo2max_percentage(vo2max, 0.88)
    }
  end

  def interval_pace(_marathon_speed, vo2max) do
    %{
      color: Colors.orange(),
      name: "Interval",
      min_speed: RacePredictor.velocity_at_vo2max_percentage(vo2max, 0.95),
      max_speed: RacePredictor.velocity_at_vo2max_percentage(vo2max, 1.0)
    }
  end

  def repetition_pace(_marathon_speed, vo2max) do
    %{
      color: Colors.red(),
      name: "Repeats",
      min_speed: RacePredictor.velocity_at_vo2max_percentage(vo2max, 1.05),
      max_speed: RacePredictor.velocity_at_vo2max_percentage(vo2max, 1.1)
    }
  end

  def tenk_pace(_marathon_speed, vo2max) do
    distance = 10_000
    t = RacePredictor.predict_race_time(distance, vo2max)

    %{
      color: Colors.orange(),
      name: "10k",
      speed: distance / t
    }
  end

  def fivek_pace(_marathon_speed, vo2max) do
    distance = 5_000
    t = RacePredictor.predict_race_time(distance, vo2max)

    %{
      color: Colors.red(),
      name: "5k",
      speed: distance / t
    }
  end

  # Base pace is your marathon pace or equivalent
  defp marathon_speed(distance, duration, vo2max) do
    if distance == marathon_in_meters() do
      distance / duration
    else
      distance = marathon_in_meters()
      duration = RacePredictor.predict_race_time(distance, vo2max)
      distance / duration
    end
  end

  defp validate_max_speed_greater_than_min_speed(changeset) do
    min_speed = get_field(changeset, :min_speed)
    max_speed = get_field(changeset, :max_speed)

    case {min_speed, max_speed} do
      {min, max} when max > min ->
        changeset

      _ ->
        add_error(
          changeset,
          :max_speed,
          "must be greater than minimum speed"
        )
    end
  end
end
