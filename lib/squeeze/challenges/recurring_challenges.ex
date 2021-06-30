defmodule Squeeze.Challenges.RecurringChallenges do
  @moduledoc """
  This module finds recurring challenges and creates the next iteration.
  """

  import Ecto.Query, warn: false
  # alias Ecto.{Changeset}
  alias Squeeze.Challenges.Challenge
  alias Squeeze.Repo

  @fields_to_clone ~w(
    name
    activity_type
    challenge_type
    timeline
    user_id
    segment_id
    polyline
    private
    recurring
  )a

  def find_and_create do
    list_recurring_challenges_ending_today()
    |> Enum.each(&create_new_challenge/1)
  end

  def create_new_challenge(challenge) do
    %Challenge{}
    |> Challenge.changeset(challenge_attrs(challenge))
    |> Repo.insert_with_slug()
  end

  def challenge_attrs(challenge) do
    challenge
    |> Map.take(@fields_to_clone)
    |> Map.merge(challenge_dates(challenge))
  end

  def challenge_dates(%{timeline: :day, start_date: date}) do
    %{
      start_date: Timex.shift(date, days: 1),
      end_date: Timex.shift(date, days: 1)
    }
  end

  def challenge_dates(%{timeline: :weekend} = challenge) do
    %{
      start_date: Timex.shift(challenge.start_date, days: 7),
      end_date: Timex.shift(challenge.end_date, days: 7)
    }
  end

  def challenge_dates(%{timeline: :week} = challenge) do
    %{
      start_date: Timex.shift(challenge.start_date, days: 7),
      end_date: Timex.shift(challenge.end_date, days: 7)
    }
  end

  def challenge_dates(%{timeline: :month} = challenge) do
    date = challenge.start_date |> Timex.shift(months: 1)
    %{
      start_date: date,
      end_date: Timex.end_of_month(date)
    }
  end

  defp list_recurring_challenges_ending_today(datetime \\ Timex.now) do
    today = datetime |> Timex.to_date()
    query = from p in Challenge,
      where: p.end_date == ^today,
      where: p.recurring == true

    Repo.all(query)
  end
end
