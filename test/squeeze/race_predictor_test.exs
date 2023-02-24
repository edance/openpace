defmodule Squeeze.RacePredictorTest do
  use ExUnit.Case

  @moduledoc false

  alias Squeeze.RacePredictor

  describe "#estimated_vo2max/2" do
    test "returns the estimated vo2max" do
      vo2max = RacePredictor.estimated_vo2max(5000, 1080)
      assert(round(vo2max) == 56)
    end
  end

  describe "#predict_race_time/2" do
    test "returns a predicted race time" do
      formatted_time =
        RacePredictor.predict_race_time(42_195, 61)
        |> Squeeze.Duration.format()

      assert(formatted_time == "2:41:03")
    end
  end

  describe "#predict_all_race_times/1" do
    test "returns all the distances" do
      result = RacePredictor.predict_all_race_times(61)
      assert(result |> Map.keys() |> length() > 1)
    end

    test "returns the predicted race times" do
      result = RacePredictor.predict_all_race_times(61)

      formatted_time =
        result
        |> Map.get(42_195)
        |> Squeeze.Duration.format()

      assert(formatted_time == "2:41:03")
    end
  end

  describe "#velocity_at_vo2max_percentage/2" do
    test "returns the velocity at vo2max percentage" do
      result =
        RacePredictor.velocity_at_vo2max_percentage(50, 0.65)
        |> Squeeze.Velocity.to_float(imperial: true)

      assert(result == 8.74)
    end
  end
end
