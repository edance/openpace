defmodule Squeeze.RacePredictor do
  @moduledoc """
  This module uses vo2_max from Daniel's Running Formula to predict other races.
  With help from this article: http://www.simpsonassociatesinc.com/runningmath9.htm
  """

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
    p = 0.8 + (0.1894393 * :math.exp(-0.012778 * min)) + (0.2989558 * :math.exp(-0.1932605 * min))

    # calculate vo2 (oxygen cost)
    v = -4.60 + (0.182258 * d) + (0.000104 * d * d)

    # calculate vo2 max
    vo2 = v / p;

    vo2
  end

  @doc """
  Calculates a predicted race time using vo2_max and a distance.

  Returns the duration (in seconds) for the given distance.

  With help from this article: http://www.simpsonassociatesinc.com/runningmath8.htm

  ## Examples

  iex> predict_race_time(42_195, 61) |> Squeeze.Duration.format()
  "2:41:02"
  """
  def predict_race_time(distance, vo2_max) do
    base_estimate(distance)
    |> newtons_method(0, ft(distance, vo2_max), derivative_t(distance, vo2_max))
    |> Kernel.*(60.0)
    |> Kernel.round()
  end

  # Returns time in minutes for distance in meters based on 6min/mile pace
  defp base_estimate(distance) do
    distance * 6 / 1609
  end

  defp newtons_method(guess, prev_guess, f, derivative) do
    precision = 0.01

    if (abs(prev_guess - guess) > precision) do
      approx = guess - f.(guess) / derivative.(guess)

      newtons_method(approx, guess, f, derivative)
    else
      guess
    end
  end

  defp ft(distance, vo2_max) do
    fn (t) ->
      (((0.000104 * :math.pow(distance, 2) * :math.pow(t, -2)) + (0.182258 * distance * :math.pow(t, -1)) -4.6) / ((0.2989558 * :math.exp( -0.1932605*t)) + (0.1894393 * :math.exp(-0.012778 * t)) + 0.8)) - vo2_max
    end
  end

  defp derivative_t(distance, vo2_max) do
    fn (t) ->
      ((((0.2989558 * :math.exp( -0.1932605*t)) + (0.1894393 * :math.exp(-0.012778*t)) + 0.8)*((-0.000208) * (:math.pow(distance, 2)) * (:math.pow(t,-3))) - ((0.182258) * distance * (:math.pow(t, -2)))) - (vo2_max * ((0.2989558)*(:math.exp( -0.1932605*t)) + (0.1894393) * (:math.exp(-0.012778*t))))) / :math.pow(((0.2989558*:math.exp( -0.1932605*t)) + (0.1894393 * :math.exp(-0.012778*t)) + 0.8), 2)
    end
  end
end
