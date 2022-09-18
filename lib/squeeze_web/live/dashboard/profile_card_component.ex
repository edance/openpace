defmodule SqueezeWeb.Dashboard.ProfileCardComponent do
  use SqueezeWeb, :live_component
  @moduledoc false

  alias Number.Delimit
  alias Squeeze.Distances

  def total_distance(%{ytd_run_stats: ytd_run_stats, current_user: user}) do
    ytd_run_stats.distance
    |> Distances.to_int([imperial: user.user_prefs.imperial])
    |> Delimit.number_to_delimited(precision: 0)
  end

  def total_hours(%{ytd_run_stats: ytd_run_stats}) do
    Delimit.number_to_delimited(ytd_run_stats.duration / (60 * 60), precision: 0)
  end

  def total_elevation(%{ytd_run_stats: ytd_run_stats, current_user: user}) do
    ytd_run_stats.elevation_gain
    |> Distances.to_feet([imperial: user.user_prefs.imperial])
    |> Delimit.number_to_delimited(precision: 0)
  end
end
