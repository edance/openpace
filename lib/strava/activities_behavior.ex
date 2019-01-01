defmodule Strava.ActivitiesBehavior do
  @moduledoc """
  Activities behavior to allow us to use mocks for Strava.Activities
  """
  @callback get_logged_in_athlete_activities(Tesla.Client, []) :: {:ok, [Strava.SummaryActivity]}
end
