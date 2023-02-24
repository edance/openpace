defmodule Squeeze.RacePredictor do
  @moduledoc """
  This module uses vo2max from Daniel's Running Formula to predict other races.
  With help from this article: http://www.simpsonassociatesinc.com/runningmath9.htm
  """

  import Squeeze.Distances, only: [distances: 0]

  @doc """
  Calculates an estimated vo2 max for a given distance and duration (race effort)

  Returns a float

  ## Examples

  iex> estimated_vo2max(5000, 1080) # 18 minute 5k
  56.319480966731284
  """
  def estimated_vo2max(distance, duration) do
    min = duration / 60.0

    # calculate velocity im metres per min
    d = distance / min

    # calculate % max (drop dead formula)
    p = 0.8 + 0.1894393 * :math.exp(-0.012778 * min) + 0.2989558 * :math.exp(-0.1932605 * min)

    # calculate vo2 (oxygen cost)
    v = -4.60 + 0.182258 * d + 0.000104 * d * d

    # calculate vo2 max
    vo2 = v / p

    vo2
  end

  @doc """
  Calculates a predicted race time using vo2max and a distance.

  Returns the duration (in seconds) for the given distance.

  With help from this article: http://www.simpsonassociatesinc.com/runningmath8.htm

  ## Examples

  iex> predict_race_time(42_195, 61) |> Squeeze.Duration.format()
  "2:41:03"
  """
  def predict_race_time(distance, vo2max) do
    base_estimate(distance)
    |> newtons_method(0, ft(distance, vo2max), derivative_t(distance, vo2max))
    |> Kernel.*(60.0)
    |> Kernel.round()
  end

  @doc """
  Calculates race time predictions for many different race distances based on vo2max

  Returns a map of distance (in meters) to time (in seconds)

  ## Examples

  ```elixir
  iex> predict_all_race_times(61)
  %{distance => time}
  ```
  """
  def predict_all_race_times(vo2max) do
    distances()
    |> Enum.reduce(%{}, fn %{distance: distance}, obj ->
      Map.put(obj, distance, predict_race_time(distance, vo2max))
    end)
  end

  @doc """
  Calculates the velocity (meters/sec) for a given vo2max and percentage.

  Say easy pace is between 65% to 70% of your vo2max pace (50). You can use this like the following:

  ```elixir
  iex> velocity_at_vo2max_percentage(50, 0.65)
  3.06818475 # meters per second (8:44 min/mile)
  ```
  """
  def velocity_at_vo2max_percentage(vo2max, percentage) do
    vo2 = vo2max * percentage
    (29.54 + 5.000663 * vo2 - 0.007546 * :math.pow(vo2, 2)) / 60
  end

  # Returns time in minutes for distance in meters based on 6min/mile pace
  defp base_estimate(distance) do
    distance * 6 / 1609
  end

  defp newtons_method(guess, prev_guess, f, derivative) do
    precision = 0.01

    if abs(prev_guess - guess) > precision do
      approx = guess - f.(guess) / derivative.(guess)

      newtons_method(approx, guess, f, derivative)
    else
      guess
    end
  end

  defp ft(distance, vo2max) do
    fn t ->
      (0.000104 * :math.pow(distance, 2) * :math.pow(t, -2) +
         0.182258 * distance * :math.pow(t, -1) - 4.6) /
        (0.2989558 * :math.exp(-0.1932605 * t) + 0.1894393 * :math.exp(-0.012778 * t) + 0.8) -
        vo2max
    end
  end

  defp derivative_t(distance, vo2max) do
    fn t ->
      ((0.2989558 * :math.exp(-0.1932605 * t) + 0.1894393 * :math.exp(-0.012778 * t) + 0.8) *
         (-0.000208 * :math.pow(distance, 2) * :math.pow(t, -3)) -
         0.182258 * distance * :math.pow(t, -2) -
         vo2max * (0.2989558 * :math.exp(-0.1932605 * t) + 0.1894393 * :math.exp(-0.012778 * t))) /
        :math.pow(
          0.2989558 * :math.exp(-0.1932605 * t) + 0.1894393 * :math.exp(-0.012778 * t) + 0.8,
          2
        )
    end
  end
end
