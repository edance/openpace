defmodule Strava.ActivitiesBehavior do
  @moduledoc """
  Activities behavior to allow us to use mocks for Strava.Activities
  """

  @callback get_logged_in_athlete_activities(Tesla.Env.client(), keyword()) ::
              {:ok, list(Strava.SummaryActivity.t())} | {:error, Tesla.Env.t()}

  @callback get_activity_by_id(Tesla.Env.client(), integer()) ::
              {:ok, Strava.DetailedActivity.t()} | {:error, Tesla.Env.t()}
end
